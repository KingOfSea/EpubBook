
#import <UIKit/UIKit.h>



@interface EpubControlNavigationBar : UIView

@property (nonatomic, copy) void (^backHandle)(void);
@property (nonatomic, copy) void (^rewardHandle)(void);
@property (nonatomic, copy) void (^moreHandle)(void);

@end
