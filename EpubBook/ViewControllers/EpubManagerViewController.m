
#import "EpubManagerViewController.h"
#import "EpubRenderViewController.h"
#import "HGDrawerViewController.h"
#import "EpubMindViewController.h"
#import "EpubMindListViewController.h"

#import "EpubMindView.h"
#import "EpubView.h"
#import "EpubControlNavigationBar.h"
#import "EpubControlPanel.h"
#import "EpubControlProgressBar.h"
#import "EpubControlFontBar.h"
#import "EpubControlNightModeBar.h"
#import "EpubControlMoreBar.h"

#import "EpubDataBase.h"
#import "EpubDefaultUtil.h"
#import "EpubViewModel.h"
#import "EpubNotificationHeader.h"
#import "CTFunction.h"

//#import "ShareSDKHandle.h"

@interface EpubManagerViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
{
    EpubBookModel *_bookModel;
    EpubParser *_epubParser;
}
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) EpubMindView *mindView;
@property (nonatomic, strong) EpubControlNavigationBar *controlNavigationBar;
@property (nonatomic, strong) EpubControlPanel *controlPanel;
@property (nonatomic, strong) EpubControlProgressBar *controlProgressView;
@property (nonatomic, strong) EpubControlNightModeBar *controlNightModeBar;
@property (nonatomic, strong) EpubControlFontBar *controlFontBar;
@property (nonatomic, strong) EpubControlMoreBar *controlMoreBar;

@property (nonatomic, strong) NSMutableArray *mindList;//从网络服务器端获取的想法列表
@property (nonatomic, assign) BOOL isMindsDownloaded;//记录当前章节是否已经下载过想法
@property (nonatomic, assign) BOOL isPageTurning;//是否正在翻页
@property (nonatomic, strong) NSString *chapterIdOfMindList;//想法列表的chapterId
@property (nonatomic, strong) EpubChapter *curChapter;//当前的epubChapter
@property (nonatomic, strong) EpubMarkModel *markModel;//选中的markModel
@property (nonatomic, assign) BOOL isPageAnimating;//避免点击过快时，动画压栈不成功产生的警告
@property (nonatomic, assign) BOOL isControlPanelShowing;//控制面板是否已经显示
@property (nonatomic, assign) BOOL isControlMoreBarShowing;//是否已经显示更多


@end


@implementation EpubManagerViewController

- (instancetype)initWithBookModel:(EpubBookModel *)bookModel epubParser:(EpubParser *)epubParser{
    self = [super init];
    if (self) {
        [self resetReadStyle];
        _bookModel = bookModel;
        _epubParser = epubParser;
        _mindList = [NSMutableArray array];
    }
    return self;
}

- (EpubBookModel *)bookModel{
    return _bookModel;
}

- (EpubParser *)epubParser{
    return _epubParser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addPageViewController:nil];
    [self addControlPanels];
    [self addNotis];
    [self parseProgress];
    
}

- (void)addControlPanels{
    [self addMindView:nil];
    [self addControlProgressView:nil];
    [self addControlNightModeBar:nil];
    [self addControlFontBar:nil];
    //控制面板
//    [self addControlMoreBar:nil];
    [self addControlNavigationBar:nil];
    [self addControlPanel];
}

- (void)addPageViewController:(NSSet *)objects{
    _pageViewController = [[UIPageViewController alloc]init];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self reloadPageViewController];
}

- (void)reloadPageViewController{
    EpubPage *epubPage = nil;
    NSArray *chapters = _epubParser.epubCatalog.chapters;
    _curChapter = _bookModel.currentChapter?chapters[_bookModel.currentChapter]:chapters.firstObject;
    EpubContent *epubContent = [_curChapter epubContent];
    NSArray *pageArray = epubContent.pages;
    EpubPage *pageModel = pageArray[0];
    for (EpubPage *page in pageArray) {
        if (page.range.location+page.range.length>_bookModel.currentIndex) {
            pageModel = page;
            break;
        }
    }
    epubPage = pageModel;
    
    EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:epubPage EpubBookModel:_bookModel];
    __weak typeof(self) weakSelf = self;
    _isPageTurning = YES;
    [_pageViewController setViewControllers:@[vc]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:^(BOOL f){
                                     [weakSelf reloadProgressWithEpubPage:vc.epubPage];
                                     weakSelf.isPageTurning = NO;
                                 }];
}

#if 1
- (void)addMindView:(NSSet *)objects{
    _mindView = [EpubMindView mindView];
    _mindView.center = self.view.center;
    _mindView.hidden = YES;
    [self.view addSubview:_mindView];
    __weak typeof(self) weakSelf = self;
    [_mindView setActionHandle:^(EpubMindViewAction action) {
        [weakSelf mindViewDidSelected:action];
    }];
}

- (void)hideMindView:(BOOL)hide{
    [self.view bringSubviewToFront:_mindView];
    _mindView.hidden = hide;
}

- (void)resetReadStyle{
    EpubReadStyle *readStyle = [EpubReadStyle sharedInstance];
    UIFont *font = [EpubDefaultUtil readFont];
    if (!font) {
        font = font?:[UIFont systemFontOfSize:14];
        [EpubDefaultUtil setReadFont:font];
    }
    readStyle.font = font;
    readStyle.bottomLineColor = [EpubMindView mindView].lineColor;
    readStyle.textColor = [EpubDefaultUtil isNightMode]?EpubReadNightTextColor:EpubReadDayTextColor;
    readStyle.linkColor = [EpubDefaultUtil isNightMode]?EpubReadNightLinkColor:EpubReadDayLinkColor;
}

- (void)addNotis{
    __weak typeof(self) weakSelf = self;
    __weak EpubReadStyle *weakReadStyle = [EpubReadStyle sharedInstance];
    [NSNotificationCenter addObserverForName:Epub_FontChanged usingBlock:^(NSNotification *note) {
        [weakSelf reloadPageViewController];
    }];
    [NSNotificationCenter addObserverForName:EpubLinkInfoClickedNotification usingBlock:^(NSNotification *note) {
        EpubLinkInfo *linkInfo = note.object;
        EpubChapter *epubChapter = [EpubViewModel getChapterWithLinkInfo:linkInfo epubCatalog:weakSelf.epubParser.epubCatalog];
        [weakSelf resetWithChapter:epubChapter];
    }];
    [NSNotificationCenter addObserverForName:Epub_NightModeChanged usingBlock:^(NSNotification *note) {
        if ([EpubDefaultUtil isNightMode]) {
            weakReadStyle.textColor = EpubReadNightTextColor;
            weakReadStyle.linkColor = EpubReadNightLinkColor;
            [weakSelf reloadPageViewController];
            weakSelf.controlPanel.backgroundColor = EpubReadNightViewColor;
            weakSelf.controlNavigationBar.backgroundColor = EpubReadNightNavColor;
            weakSelf.controlMoreBar.backgroundColor = EpubReadNightNavColor;
            return;
        }
        weakReadStyle.textColor = EpubReadDayTextColor;
        weakReadStyle.linkColor = EpubReadDayLinkColor;
        [weakSelf reloadPageViewController];
        weakSelf.controlPanel.backgroundColor = [UIColor whiteColor];
        weakSelf.controlNavigationBar.backgroundColor = EpubReadDayNavColor;
        weakSelf.controlMoreBar.backgroundColor = EpubReadDayNavColor;
        return;
    }];
    [NSNotificationCenter addObserverForName:EpubMarkChoosed usingBlock:^(NSNotification *note) {
        weakSelf.markModel = note.object;
        [weakSelf hideMindView:!weakSelf.mindView.hidden];
    }];
    [NSNotificationCenter addObserverForName:EpubDataBaseMarkTableDelete usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = note.userInfo;
        EpubMarkModel *markModel = userInfo[@"MarkModel"];
        NSMutableArray *temp_MindList = [NSMutableArray arrayWithArray:weakSelf.mindList];
        for (EpubMarkModel *model in weakSelf.mindList) {
            if (markModel == model) {
                [temp_MindList removeObject:model];
            }
        }
        [weakSelf.mindList removeAllObjects];
        [weakSelf.mindList addObjectsFromArray:temp_MindList];
    }];
    [NSNotificationCenter addObserverForName:EpubBadgeButtonClickedNotification usingBlock:^(NSNotification *note) {
        NSArray *arr = note.object;
        NSLog(@"%@",note.object);
        EpubMindListViewController *vc = [EpubMindListViewController new];
        vc.mindList = arr;
        [weakSelf.fatherController.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)addControlNavigationBar:(NSSet *)objects{
    _controlNavigationBar = [[EpubControlNavigationBar alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, 64)];
    __weak typeof(self) weakSelf = self;
    [_controlNavigationBar setBackHandle:^{
        [weakSelf.fatherController.navigationController popViewControllerAnimated:YES];
    }];
    [_controlNavigationBar setMoreHandle:^{
        if (weakSelf.isControlMoreBarShowing) {
            [weakSelf hideControlMoreBar:YES animate:YES];
        }else{
            [weakSelf hideControlMoreBar:NO animate:YES];
        }
    }];
    [self.view addSubview:_controlNavigationBar];
}

//- (void)addControlMoreBar:(NSSet *)objects{
//    _controlMoreBar = [[EpubControlMoreBar alloc]initWithFrame:CGRectMake(self.view.frame.size.width-105, -135, 105, 135)];
//    __weak typeof(self) weakSelf = self;
//    [_controlMoreBar setShareHandle:^{
//        
//        NSString *bookName = weakSelf.model.articleName;
//        NSString *articleId = weakSelf.model.articleId;
//        NSString *type = @"1"; //book
//        NSString *imageStr = weakSelf.model.coverUrl;
//        [BKShareHandle shareContent:bookName shareType:type contentId:articleId imageStr:imageStr];
//    }];
//    [_controlMoreBar setTipoffHandle:^{
//        BKTipoffsViewController *tipoffsViewController = [[BKTipoffsViewController alloc]init];
//        tipoffsViewController.model = weakSelf.model;
//        [weakSelf.fatherController.navigationController pushViewController:tipoffsViewController animated:YES];
//    }];
//    [_controlMoreBar setMarkHandle:^{
//        [weakSelf addBookMark];
//    }];
//    [self.view addSubview:_controlMoreBar];
//}

- (void)addControlPanel{
    _controlPanel = [[EpubControlPanel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 50)];
    __weak typeof(self) weakSelf = self;
    [_controlPanel setPanelClick:^(EpubControlPanelType type) {
        [weakSelf panelClickWithType:type];
    }];
    [self.view addSubview:_controlPanel];
}

- (void)addControlProgressView:(NSSet *)objects{
    _controlProgressView = [[EpubControlProgressBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 60)];
    __weak typeof(self) weakSelf = self;
    [_controlProgressView setChooseChapter:^(EpunControlProgressBtnType type) {
        EpubRenderViewController *vc = weakSelf.pageViewController.viewControllers.firstObject;
        EpubChapter *chapter = vc.epubPage.epubContent.epubChapter;
        chapter = (type == EpunControlProgressBtnTypeLast)?chapter.lastChapter:chapter.nextChapter;
        [weakSelf resetWithChapter:chapter];
    }];
    [_controlProgressView setChooseProgress:^(CGFloat progress) {
        [weakSelf resetWithProgress:progress];
    }];
    [self.view addSubview:_controlProgressView];
}

- (void)addControlFontBar:(NSSet *)objects{
    _controlFontBar = [[EpubControlFontBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 60)];
    [self.view addSubview:_controlFontBar];
}

- (void)addControlNightModeBar:(NSSet *)objects{
    _controlNightModeBar = [[EpubControlNightModeBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 60)];
    [self.view addSubview:_controlNightModeBar];
}

- (void)parseProgress{
    
    [_epubParser parseProgressCompletion:^(NSInteger totalLength) {
        EpubRenderViewController *curViewController = _pageViewController.childViewControllers.firstObject;
        EpubPage *pageModel = curViewController.epubPage;
        [self reloadProgressWithEpubPage:pageModel];
    }];
}

- (void)reloadProgressWithEpubPage:(EpubPage *)epubPage{
    if (_epubParser.epubCatalog.totalLength == 0) {
        return;
    }

    EpubChapter *epubChapter = epubPage.epubContent.epubChapter;
    NSInteger offset = NSRangeGetEndLocation(epubPage.range)+epubChapter.rangeInTotal.location;
    NSInteger total = epubChapter.epubCatalog.totalLength;
    
    CGFloat progress = offset/(total*1.0);
    _controlProgressView.progress = progress;
}


#pragma mark - 根据进度跳转对应章节
- (void)resetWithProgress:(CGFloat)progress{
    NSInteger location = progress*(_epubParser.epubCatalog.totalLength-1);
    location = location>=0?location:0;
    NSInteger index = 0;
    EpubContent *epubContent = nil;
    EpubPage *newPageModel = nil;
    
    for (; index<_epubParser.epubCatalog.chapters.count; index++) {
        EpubChapter *epubChapter = _epubParser.epubCatalog.chapters[index];
        if (NSRangeContainsLocation(epubChapter.rangeInTotal, location)) {
            epubContent = epubChapter.epubContent;
            
            NSInteger locationInChapter = location-epubChapter.rangeInTotal.location;
            NSArray *pages = epubContent.pages;
            for (EpubPage *pageModel in pages) {
                if (NSRangeContainsLocation(pageModel.range, locationInChapter)) {
                    newPageModel = pageModel;
                    break;
                }
            }
            
            break;
        }
    }
    if (![self isBookHasBuyedWithChapter:newPageModel.epubContent.epubChapter]) {
        return;
    }
    EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:newPageModel EpubBookModel:_bookModel];
    
    __weak typeof(self) weakSelf = self;
    _isPageTurning = YES;
    [_pageViewController setViewControllers:@[vc]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:^(BOOL finished){
                                     if (finished) {
                                         [weakSelf pageViewControllerHasFinishedAnimate:vc];
                                     }
                                 }];
    
}

#pragma mark - 根据书签或者想法跳转对应章节
- (void)resetWithMarkModel:(EpubMarkModel *)markModel{
    EpubRenderViewController *curVC = _pageViewController.viewControllers.firstObject;
    EpubChapter *epubChapter = _epubParser.epubCatalog.chapters[markModel.playOrder];
    EpubContent *epubContent = epubChapter.epubContent;
    NSArray *pageArray = epubContent.pages;
    EpubPage *pageModel = pageArray.firstObject;
    for (EpubPage *page in pageArray) {
        if (page.range.location+page.range.length>markModel.indexStart) {
            pageModel = page;
            break;
        }
    }
    EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:pageModel EpubBookModel:_bookModel];
    
    UIPageViewControllerNavigationDirection direction;
    if (curVC.epubPage.epubContent.epubChapter.playOrder<markModel.playOrder) {
        direction = UIPageViewControllerNavigationDirectionForward;
    }else{
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    __weak typeof(self) weakSelf = self;
    _isPageTurning = YES;
    [self.pageViewController setViewControllers:@[vc] direction:direction animated:YES completion:^(BOOL finished) {
        
        if (finished) {
            [weakSelf pageViewControllerHasFinishedAnimate:vc];
        }
    }];
}
#pragma mark - 根据章节跳转
- (void)resetWithChapter:(EpubChapter *)chapter{
    if (!chapter) {
        return;
    }
    if (![self isBookHasBuyedWithChapter:chapter]) {
        return;
    }
    EpubRenderViewController *curVC = _pageViewController.viewControllers.firstObject;
    EpubContent *epubContent = chapter.epubContent;
    NSArray *pageArray = epubContent.pages;
    EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:pageArray.firstObject EpubBookModel:_bookModel];
    UIPageViewControllerNavigationDirection direction;
    if (curVC.epubPage.epubContent.epubChapter.playOrder<chapter.playOrder) {
        direction = UIPageViewControllerNavigationDirectionForward;
    }else{
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    __weak typeof(self) weakSelf = self;
    _isPageTurning = YES;
    [self.pageViewController setViewControllers:@[vc] direction:direction animated:YES completion:^(BOOL finished) {
//        if (finished) {
        [weakSelf pageViewControllerHasFinishedAnimate:vc];
//        }
        
    }];
    
}

#endif

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    if (_isPageAnimating) {
        return nil;
    }
    
    EpubRenderViewController *curViewController = (EpubRenderViewController *)viewController;
    
    if (curViewController.epubPage.nextPage == nil) {//如果当前页是最后一页
        EpubChapter *nextChapter = curViewController.epubPage.epubContent.epubChapter.nextChapter;
        if (nextChapter) {//若有下一章节
//            if (![self isBookHasBuyedWithChapter:nextChapter]) {
//                return nil;
//            }
            EpubContent *epubContent = nextChapter.epubContent;
            NSArray *pageArray = epubContent.pages;
            while (!pageArray.count) {
                if (!nextChapter.nextChapter) {
//                    [self showHudWithTitle:@"已是最后一页" detail:nil];
                    if (_pageDidTurnEndOfBook) {
                        _pageDidTurnEndOfBook(pageViewController, UIPageViewControllerNavigationDirectionReverse);
                    }
                    return nil;
                }
                nextChapter = nextChapter.nextChapter;
                epubContent = nextChapter.epubContent;
                pageArray = epubContent.pages;
            }
            EpubPage *epubPage = pageArray.firstObject;
            EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:epubPage EpubBookModel:_bookModel];
//            vc.bookModel = _bookModel;
//            if ([self isSameChapterWithEpubPage:vc.pageModel]) {
//                vc.mindModels = _mindList;
//            }
            return vc;
        }
        //若没有下一章节
        if (_pageDidTurnEndOfBook) {
            _pageDidTurnEndOfBook(pageViewController, UIPageViewControllerNavigationDirectionReverse);
        }
//        [self showHudWithTitle:@"已是最后一页" detail:nil];
        return nil;
    }
    
    EpubPage *epubPage = curViewController.epubPage.nextPage;
    EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:epubPage EpubBookModel:_bookModel];
    
//    vc.bookModel = _bookModel;
//    if ([self isSameChapterWithEpubPage:vc.pageModel]) {
//        vc.mindModels = _mindList;
//    }
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    if (_isPageAnimating) {
        return nil;
    }
    
    EpubRenderViewController *curViewController = (EpubRenderViewController *)viewController;
    if (curViewController.epubPage.lastPage == nil) {//如果当前页是第一页
        EpubChapter *lastChapter = curViewController.epubPage.epubContent.epubChapter.lastChapter;
        if (lastChapter) {//若有上一章节
            
            EpubContent *epubContent = lastChapter.epubContent;
            NSArray *pageArray = epubContent.pages;
            while (!pageArray.count) {
                if (!lastChapter.lastChapter) {
//                    [self showHudWithTitle:@"已是第一页" detail:nil];
                    if (_pageDidTurnEndOfBook) {
                        _pageDidTurnEndOfBook(pageViewController, UIPageViewControllerNavigationDirectionForward);
                    }
                    return nil;
                }
                lastChapter = lastChapter.lastChapter;
                epubContent = lastChapter.epubContent;
                pageArray = epubContent.pages;
            }
            EpubPage *epubPage = pageArray.lastObject;
            EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:epubPage EpubBookModel:_bookModel];
            return vc;
        }
//        [self showHudWithTitle:@"已是第一页" detail:nil];
        if (_pageDidTurnEndOfBook) {
            _pageDidTurnEndOfBook(pageViewController, UIPageViewControllerNavigationDirectionForward);
        }
        return nil;
    }
    EpubPage *epubPage = curViewController.epubPage.lastPage;
    EpubRenderViewController *vc = [[EpubRenderViewController alloc]initWithEpubPage:epubPage EpubBookModel:_bookModel];
    return vc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    EpubRenderViewController *curViewController = pageViewController.childViewControllers.firstObject;
    EpubRenderViewController *preViewController = (EpubRenderViewController *)previousViewControllers.firstObject;
    if (!completed) {//若翻页未完成，修改
        curViewController = preViewController;
    }
    if (finished) {
        _isPageAnimating = NO;
        self.view.userInteractionEnabled = YES;
        [self pageViewControllerHasFinishedAnimate:curViewController];
    }
    if (_pageDidTurnFinish) {
        _pageDidTurnFinish(pageViewController, completed, finished);
    }
}

- (void)pageViewControllerHasFinishedAnimate:(EpubRenderViewController *)renderViewController{
    [self reloadProgressWithEpubPage:renderViewController.epubPage];
    _curChapter = renderViewController.epubPage.epubContent.epubChapter;
    
    _bookModel.currentIndex = renderViewController.epubPage.range.location;
    _bookModel.currentChapter = renderViewController.epubPage.epubContent.epubChapter.playOrder;
    [EpubDataBase updateBookWithBookModel:_bookModel];
    _isPageTurning = YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    _isPageAnimating = YES;
    self.view.userInteractionEnabled = NO;
    if (_pageWillTransition) {
        _pageWillTransition(pageViewController);
    }
    [self hideAllControlItems];
}

#pragma mark - 页面手势的响应事件
#if 1
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (!_mindView.hidden) {
        _mindView.hidden = YES;
        return;
    }
    [self hideControlPanel:_isControlPanelShowing];
    if (_isControlPanelShowing) {
        [self hideAllControlItems];
    }
}

- (void)hideControlMoreBar:(BOOL)hide animate:(BOOL)animate{
    CGRect frame = _controlMoreBar.frame;
    frame.origin.y = hide?-frame.size.height:0+64;
    NSTimeInterval duration = animate?0.25:0;
    [UIView animateWithDuration:duration animations:^{
        _controlMoreBar.frame = frame;
    }completion:^(BOOL finished) {
        _isControlMoreBarShowing = !hide;
    }];
}

- (void)hideControlPanel:(BOOL)hide{
//    [self.view bringSubviewToFront:_controlMoreBar];
    self.view.userInteractionEnabled = NO;
    CGRect frame = _controlPanel.frame;
    frame.origin.y = hide?self.view.frame.size.height:self.view.frame.size.height-frame.size.height;
    
    CGRect frame_nav = _controlNavigationBar.frame;
    frame_nav.origin.y = hide?-64:0;
    
    [UIView animateWithDuration:0.25 animations:^{
        _controlPanel.frame = frame;
        _controlNavigationBar.frame = frame_nav;
    }completion:^(BOOL finished) {
        if (!_isPageAnimating/*!_isPageAnimating&&!_isDrawerShow&&!_isPageAnimating*/) {
            self.view.userInteractionEnabled = YES;
        }
        _isControlPanelShowing = !hide;
        [self.fatherController setNeedsStatusBarAppearanceUpdate];
        for (UIViewController *viewController in _pageViewController.viewControllers) {
            viewController.view.userInteractionEnabled = !_isControlPanelShowing;
        }
    }];
}

- (void)hideAllControlItems{
    [self hideMindView:YES];
    [self hideControlPanel:YES];
    [self hideControlItem:_controlProgressView hide:YES];
    [self hideControlItem:_controlNightModeBar hide:YES];
    [self hideControlItem:_controlFontBar hide:YES];
    [self hideControlMoreBar:YES animate:NO];
}

- (void)hideControlItem:(UIView *)controlItem hide:(BOOL)hide{
    [self.view bringSubviewToFront:controlItem];
    self.view.userInteractionEnabled = NO;
    CGRect frame = controlItem.frame;
    frame.origin.y = hide?self.view.frame.size.height:self.view.frame.size.height-frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        controlItem.frame = frame;
    }completion:^(BOOL finished) {
        if (!_isPageAnimating/*!_isPageAnimating&&!_isDrawerShow&&!_isPageAnimating*/) {
            self.view.userInteractionEnabled = YES;
        }
        
        for (UIViewController *viewController in _pageViewController.viewControllers) {
            viewController.view.userInteractionEnabled = !hide;
        }
    }];
}


- (void)panelClickWithType:(EpubControlPanelType)type{
    switch (type) {
        case EpubControlPanelTypeMenu:
        {
//            [self hideControlPanel:YES];
            [self hideAllControlItems];
            if (_menuShow) {
                _menuShow();
            }
        }
            break;
        case EpubControlPanelTypeProgress:
        {
            [self hideControlItem:_controlProgressView hide:NO];
        }
            break;
        case EpubControlPanelTypeDaynight:
        {
            [self hideControlItem:_controlNightModeBar hide:NO];
        }
            break;
        case EpubControlPanelTypeFont:
        {
            [self hideControlItem:_controlFontBar hide:NO];
        }
            break;
        default:
            break;
    }
}

- (void)mindViewDidSelected:(EpubMindViewAction)action{
    switch (action) {
        case EpubMindViewActionCopy:
        {
            [UIPasteboard generalPasteboard].string = _markModel.markContent;
        }
            break;
        case EpubMindViewActionMind:
        {
            [self hideMindView:YES];
            [self presentMindViewController];
        }
            break;
        case EpubMindViewActionShare:
        {
            
        }
            break;
        case EpubMindViewActionDelete:
        {
            [self hideMindView:YES];
//            [self showWaitHudWithTitle:nil];
            [EpubDataBase deleteMarkWithMarkModel:_markModel];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)presentMindViewController{
    EpubMindViewController *mindViewController = [[EpubMindViewController alloc]init];
    mindViewController.markModel = _markModel;
    mindViewController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    //必要配置
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    rootViewController.providesPresentationContextTransitionStyle = YES;
    rootViewController.definesPresentationContext = YES;
    
    [rootViewController presentViewController:mindViewController animated:YES completion:nil];    
}


- (void)addBookMark{
    [self hideControlMoreBar:YES animate:YES];
    EpubRenderViewController *curVC = _pageViewController.viewControllers.firstObject;
    EpubPage *pageModel = curVC.epubPage;
    BOOL insertResult = [EpubViewModel addBookMarkWithRange:pageModel.range epubPage:pageModel epubBookModel:_bookModel];
    if (insertResult) {
        NSLog(@"添加书签成功");
    }else{
        NSLog(@"书签已存在");
    }
}

- (BOOL)isBookHasBuyedWithChapter:(EpubChapter *)chapter{
    if (!_bookModel.isBuy&&_bookModel.freeChapNum<=chapter.playOrder) {
        NSLog(@"购买后可以查看后续章节");
        return NO;
    }
    return YES;
}

#endif

- (BOOL)prefersStatusBarHidden{
    if (_isControlPanelShowing) {
        return NO;
    }
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    //返回白色
    return UIStatusBarStyleLightContent;
}

- (void)dealloc{
    NSLog(@"000000000");
}

@end
