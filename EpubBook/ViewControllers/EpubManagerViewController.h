

#import <UIKit/UIKit.h>
//#import "BKRootViewController.h"
//#import "EpubManager.h"
//#import "BookModel.h"
#import "EpubRenderViewController.h"
#import "EpubParser.h"
@interface EpubManagerViewController : UIViewController

@property (nonatomic, weak) UIViewController *fatherController;
@property (nonatomic, strong, readonly) EpubBookModel *bookModel;
//@property (nonatomic, strong, readonly) EpubParser *epubParser;
//@property (nonatomic, strong) BookModel *model;
//
@property (nonatomic, copy) void (^menuShow)(void);
//
- (instancetype)initWithBookModel:(EpubBookModel *)bookModel epubParser:(EpubParser *)epubParser;
//
- (void)resetWithChapter:(EpubChapter *)chapter;

- (void)resetWithMarkModel:(EpubMarkModel *)markModel;

@property (nonatomic, copy) void (^pageDidTurnEndOfBook)(UIPageViewController *pageViewController, UIPageViewControllerNavigationDirection direction);
@property (nonatomic, copy) void (^pageDidTurnFinish)(UIPageViewController *pageViewController, BOOL completed, BOOL finished);
@property (nonatomic, copy) void (^pageWillTransition)(UIPageViewController *pageViewController);

@end
