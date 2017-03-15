
#import "EpubRenderViewController.h"
#import "EpubMindView.h"
#import "EpubViewModel.h"

//#import "EpubControlNightModeBar.h"
#import "EpubDefaultUtil.h"
#import "EpubNotificationHeader.h"
#import "CTFunction.h"

NSString * const EpubMarkChoosed = @"EpubMarkChoosed";

@interface EpubRenderViewController ()<UIGestureRecognizerDelegate>{
    EpubPage *_epubPage;
    EpubBookModel *_bookModel;
    EpubView *_epubView;
}
@property (nonatomic, copy) NSArray *relativeMindModels;
@property (nonatomic, copy) NSArray *relativeLinkInfos;
//@property (nonatomic, copy) NSArray *selectedRanges;
@property (nonatomic, copy) NSArray *badgeArray;

//@property (nonatomic, strong) EpubMarkModel *selMarkModel;


@end

@implementation EpubRenderViewController

- (instancetype)initWithEpubPage:(EpubPage *)epubPage EpubBookModel:(EpubBookModel *)bookModel{
    if (self = [super init]) {
        _epubPage = epubPage;
        _bookModel = bookModel;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addEpubView:nil];
    [self renderEpubView];
    [self addNotis];
}

- (void)addEpubView:(NSSet *)objects{
    EpubView *epubView = [[EpubView alloc]initWithFrame:self.view.bounds];
    epubView.epubPage = _epubPage;
    [self.view addSubview:epubView];
    _epubView = epubView;
    
    
    __weak typeof(self) weakSelf = self;
    [_epubView longPressDoing:^(CFRange range, EpubView *epubView) {
        [epubView drawBottomLineWithRange:range];
    } done:^(CFRange range, EpubView *epubView) {
        [EpubViewModel setSelectedRangeWithRange:CFRangeTransferToNSRange(range)
                                      mindModels:weakSelf.relativeMindModels
                                        epubPage:weakSelf.epubPage
                                   epubBookModel:weakSelf.bookModel];
    }];
    [_epubView setSingleClick:^BOOL(NSInteger index, EpubView *epubView) {
        return [weakSelf isEpubViewCanResponse:index];
    }];
    if (![EpubDefaultUtil isNightMode]) {
        epubView.backgroundColor = EpubReadDayColor;
    }else{
        epubView.backgroundColor = EpubReadNightColor;
    }
}

- (BOOL)isEpubViewCanResponse:(NSInteger)index{
    if (index == kCFNotFound) {
        return NO;
    }
    for (EpubLinkInfo *linkInfo in _relativeLinkInfos) {
        if (NSRangeContainsLocation(linkInfo.range, index)) {
            NSLog(@"%@",linkInfo.redirectionURL);
            [NSNotificationCenter postNotificationName:EpubLinkInfoClickedNotification object:linkInfo];
            return YES;
        }
    }
    
    for (EpubMarkModel *markModel in _relativeMindModels) {
        NSRange range = NSMakeRange(markModel.indexStart, markModel.indexEnd- markModel.indexStart+1);
        if (NSRangeContainsLocation(range,index)) {
            //Do sth
            [NSNotificationCenter postNotificationName:EpubMarkChoosed object:markModel];
            return YES;
        }
    }
    return NO;
}



- (void)renderEpubView{
    
    [EpubViewModel getRalativeMindModelsInEpubPage:_epubPage
                                     epubBookModel:_bookModel
                                        completion:^(NSArray *relativeMindModels, NSArray *relativeRanges) {
        _relativeMindModels = relativeMindModels;
        [EpubViewModel getBadgesWithMarkModels:relativeMindModels
                                      epubPage:_epubPage
                                 epubBookModel:_bookModel
                                    completion:^(NSArray *badges) {
            [_epubView drawAllLinesWithSelectRanges:relativeRanges badges:nil];
        }];
    }];
    
    [EpubViewModel getRalativeLinkInfosInEpubPage:_epubPage epubBookModel:_bookModel completion:^(NSArray *relativeLinks) {
        _relativeLinkInfos = relativeLinks;
    }];
}

#if 1

- (void)addNotis{
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:EpubMindViewColorChanged object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.epubView setNeedsDisplay];
    }];
    
    [NSNotificationCenter addObserverForName:EpubDataBaseMarkTableDelete usingBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger indexStart = strongSelf.epubPage.range.location;
        NSInteger indexEnd = strongSelf.epubPage.range.location+strongSelf.epubPage.range.length-1;
        NSInteger playOrder = strongSelf.epubPage.epubContent.epubChapter.playOrder;
        
        EpubMarkModel *markModel = note.userInfo[@"MarkModel"];
        NSMutableArray *mindModels = [NSMutableArray arrayWithArray:strongSelf.relativeMindModels];
        for (EpubMarkModel *model in strongSelf.relativeMindModels) {
            if ([markModel.markId isEqualToString:model.markId]) {
                [mindModels removeObject:markModel];
            }
        }
        strongSelf.relativeMindModels = mindModels;
        if (markModel.playOrder == playOrder) {
            if (!(markModel.indexEnd<indexStart||markModel.indexStart>indexEnd)) {
                [strongSelf renderEpubView];
            }
        }
    }];
    [NSNotificationCenter addObserverForName:EpubDataBaseMarkTableUpdate usingBlock:^(NSNotification *note) {
        
        NSInteger indexStart = weakSelf.epubPage.range.location;
        NSInteger indexEnd = weakSelf.epubPage.range.location+weakSelf.epubPage.range.length-1;
        NSInteger playOrder = weakSelf.epubPage.epubContent.epubChapter.playOrder;
        
        EpubMarkModel *markModel = note.userInfo[@"MarkModel"];
        if (markModel.playOrder == playOrder) {
            if (!(markModel.indexEnd<indexStart||markModel.indexStart>indexEnd)) {
                [weakSelf renderEpubView];
            }
        }
    }];

}

#endif
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dealloc{
    NSLog(@"3333333333333");
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    //返回白色
    return UIStatusBarStyleLightContent;
}


@end
