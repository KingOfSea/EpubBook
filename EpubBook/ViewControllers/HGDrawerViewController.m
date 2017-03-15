

#import "HGDrawerViewController.h"
NSString * const HGDrawerViewControllerHasShow = @"HGDrawerViewControllerHasShow";
NSString * const HGDrawerViewControllerAnimating = @"HGDrawerViewControllerAnimating";
NSString * const HGDrawerViewControllerHasHide = @"HGDrawerViewControllerHasHide";
NSString * const HGDrawerViewControllerWillShow = @"HGDrawerViewControllerWillShow";
NSString * const HGDrawerViewControllerWillHide = @"HGDrawerViewControllerWillHide";

@interface HGDrawerMaskView : UIView

@property (nonatomic, copy) void (^touchEnded)(void);

@end

@implementation HGDrawerMaskView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesEnded:touches withEvent:event];
    if (_touchEnded) {
        _touchEnded();
    }
}

@end


@interface HGDrawerViewController (){
    UIView *_mainView;
    UIView *_drawerView;
    HGDrawerMaskView *_maskView;
    BOOL _isDrawerShow;
}

@end

@implementation HGDrawerViewController

- (instancetype)initWithMainView:(UIView *)mainView drawerView:(UIView *)drawerView{
    self = [super init];
    if (self) {
        _mainView = mainView;
        _drawerView = drawerView;
        _drawerView.hidden = YES;
        _drawerRatio = 0.8;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _mainView.frame = self.view.bounds;
    [self.view addSubview:_mainView];
    
    _maskView = [[HGDrawerMaskView alloc]initWithFrame:self.view.bounds];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0;
    __weak typeof(self) weakSelf = self;
    [_maskView setTouchEnded:^{
        [weakSelf showDrawerView:NO];
    }];
    [self.view addSubview:_maskView];
    
    _drawerView.frame = CGRectMake(-self.view.frame.size.width*_drawerRatio, 0, self.view.frame.size.width*_drawerRatio, self.view.frame.size.height);
    [self.view addSubview:_drawerView];
    
}

- (UIView *)drawerView{
    return _drawerView;
}

- (UIView *)mainView{
    return _mainView;
}

- (BOOL)isDrawerShow{
    return _isDrawerShow;
}

- (void)showDrawerView:(BOOL)show{
//    _mainView.userInteractionEnabled = !show;
    _drawerView.hidden = NO;
    self.view.userInteractionEnabled = NO;
    CGRect drawer_frame = _drawerView.frame;
    drawer_frame.origin.x = show?0:drawer_frame.size.width*(-1);
    CGRect main_frame = _mainView.frame;
    main_frame.origin.x = show?drawer_frame.size.width:0;
    CGFloat alpha = show?0.3:0;
    if (show) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HGDrawerViewControllerWillShow object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:HGDrawerViewControllerWillHide object:nil];
    }
    
    [UIView animateWithDuration:0.125 animations:^{
        _mainView.frame = main_frame;
        _drawerView.frame = drawer_frame;
        _maskView.alpha = alpha;
    }completion:^(BOOL finished) {
        _isDrawerShow = show;
        _drawerView.hidden = !show;
        self.view.userInteractionEnabled = YES;
        if (show) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HGDrawerViewControllerHasShow object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:HGDrawerViewControllerHasHide object:nil];
        }
        
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    //返回白色
    return UIStatusBarStyleLightContent;
}

@end
