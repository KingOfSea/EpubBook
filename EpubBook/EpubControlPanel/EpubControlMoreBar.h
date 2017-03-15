

#import <UIKit/UIKit.h>

@interface EpubControlMoreBar : UIView

@property (nonatomic, strong) void (^shareHandle)(void);
@property (nonatomic, strong) void (^tipoffHandle)(void);
@property (nonatomic, strong) void (^markHandle)(void);
@end
