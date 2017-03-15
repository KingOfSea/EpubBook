
#import <UIKit/UIKit.h>

extern NSString * const HGDrawerViewControllerHasShow;
extern NSString * const HGDrawerViewControllerAnimating;
extern NSString * const HGDrawerViewControllerHasHide;
extern NSString * const HGDrawerViewControllerWillShow;
extern NSString * const HGDrawerViewControllerWillHide;

@interface HGDrawerViewController : UIViewController

@property (nonatomic, strong, readonly) UIView *mainView;
@property (nonatomic, strong, readonly) UIView *drawerView;
@property (nonatomic, readonly) BOOL isDrawerShow;

@property (nonatomic, assign) CGFloat drawerRatio;//抽屉的比例

- (instancetype)initWithMainView:(UIView *)mainView drawerView:(UIView *)drawerView;

- (void)showDrawerView:(BOOL)show;

@end
