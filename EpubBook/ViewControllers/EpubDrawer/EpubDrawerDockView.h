
#import <UIKit/UIKit.h>

@interface EpubDrawerDockView : UIView

@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) UIColor *titleColor;
@property (nonatomic, copy) UIColor *seplineColor;

@property (nonatomic, copy) void (^clickHandle)(NSInteger index,EpubDrawerDockView *drawerDockView);

@end
