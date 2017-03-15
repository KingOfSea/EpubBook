
#import "EpubReaderViewController.h"
#import "EpubMenuViewController.h"
#import "EpubManagerViewController.h"
#import "HGDrawerViewController.h"

#import "EpubDefaultUtil.h"
#import "FileManagerUtil.h"
#import "EpubParser.h"
#import "SSZipArchive.h"

@interface EpubReaderViewController ()
@property (nonatomic, strong) EpubManagerViewController *mainViewController;
@property (nonatomic, strong) EpubMenuViewController *menuViewController;
@property (nonatomic, strong) HGDrawerViewController *drawerViewController;

@property (nonatomic, strong) EpubParser *epubParser;

@end

@implementation EpubReaderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    if ([EpubDefaultUtil isNightMode]) {
        self.view.backgroundColor = EpubReadNightColor;
    }else{
        self.view.backgroundColor = EpubReadDayColor;
    }
    
    NSString *bookId = @"123";
    _epubParser = [EpubParser new];
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queue, ^{
        [self downloadWithBookId:bookId];
    });
    dispatch_group_async(group, queue, ^{
        [self parseEpubBookWithBookId:bookId];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self showWithBookModel:_bookModel epubParser:_epubParser];
    });
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)downloadWithBookId:(NSString *)bookId{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"小王子" ofType:@"epub"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    //模拟下载
    NSString *filePath = [NSString stringWithFormat:@"Documents/books/%@.epub",bookId];
    filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    [FileManagerUtil cycleCreateWithPath:filePath];
    [data writeToFile:filePath atomically:YES];
    //解压
    EpubBookModel *bookModel = [EpubBookModel new];
    bookModel.isBuy = YES;
    bookModel.bookId = bookId;
    if ([self unzipWithBookId:bookModel.bookId]) {
        //插入数据库
        [EpubDataBase insertBookWithBookModel:bookModel];
    }
    
}

- (BOOL)unzipWithBookId:(NSString *)bookId{
    NSString *epubPath = [NSString stringWithFormat:@"Documents/books/%@.epub",bookId];
    epubPath = [NSHomeDirectory() stringByAppendingPathComponent:epubPath];
    NSString * zipPath = [NSString stringWithFormat:@"Documents/EpubSDK/EpubDirectory/%@/",bookId];
    zipPath = [NSHomeDirectory() stringByAppendingPathComponent:zipPath];
    NSFileManager *filemanager=[NSFileManager defaultManager];
    //存在，已经解压过，返回路径
    if ([filemanager fileExistsAtPath:zipPath]) {
        return YES;
    }
    return [SSZipArchive unzipFileAtPath:epubPath toDestination:zipPath];
}

- (void)parseEpubBookWithBookId:(NSString *)bookId{
    _bookModel = [EpubDataBase bookModelWithBookId:bookId];
    
    NSString *rootPath = [NSString stringWithFormat:@"Documents/EpubSDK/EpubDirectory/%@/",bookId];
    rootPath = [NSHomeDirectory() stringByAppendingPathComponent:rootPath];
    [_epubParser parseToCatalogWithRootPath:rootPath];
}



- (void)showWithBookModel:(EpubBookModel *)bookModel epubParser:(EpubParser *)epubParser{
    _mainViewController = [[EpubManagerViewController alloc]initWithBookModel:bookModel epubParser:_epubParser];
    _mainViewController.fatherController = self;
    [_mainViewController setPageDidTurnEndOfBook:^(UIPageViewController *pageVC, UIPageViewControllerNavigationDirection direction) {
        if (direction == UIPageViewControllerNavigationDirectionForward) {
            NSLog(@"没有上一页");
        }else{
            NSLog(@"没有下一页");
        }
    }];
    _menuViewController = [[EpubMenuViewController alloc]initWithBookModel:bookModel epubParser:_epubParser];
    _drawerViewController = [[HGDrawerViewController alloc]initWithMainView:_mainViewController.view drawerView:_menuViewController.view];
//    [self addChildViewController:_mainViewController];
    __weak typeof(self) weakSelf = self;
    [_mainViewController setMenuShow:^{
        [weakSelf.drawerViewController showDrawerView:YES];
    }];
    [_menuViewController setCatalogClick:^(EpubChapter *chapter) {
        [weakSelf.drawerViewController showDrawerView:NO];
        [weakSelf.mainViewController resetWithChapter:chapter];
    }];
    [_menuViewController setMarkClick:^(EpubMarkModel *markModel) {
        [weakSelf.drawerViewController showDrawerView:NO];
        [weakSelf.mainViewController resetWithMarkModel:markModel];
    }];
    [self.view addSubview:_drawerViewController.view];
    [self transitionSelf];
//    UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOp animations:<#^(void)animations#> completion:<#^(BOOL finished)completion#>

}

- (void)transitionSelf{
    CATransition * transition = [CATransition animation];
    [transition setFillMode:kCAFillModeForwards];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [transition setType:kCATransition];//或者rippleEffect
    [transition setSubtype:kCATransitionFromTop];
    //transition.speed = 0.5;
    transition.duration = 0.4;
    transition.removedOnCompletion = YES;
    [self.view.layer addAnimation:transition forKey:nil];
}



- (BOOL)prefersStatusBarHidden{
    if (_mainViewController) {
        return _mainViewController.prefersStatusBarHidden;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    //返回白色
    return UIStatusBarStyleLightContent;
}

- (void)dealloc{
    NSLog(@"222222222");
}

@end
