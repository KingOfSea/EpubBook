
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EpunControlProgressBtnType) {
    EpunControlProgressBtnTypeLast = 0,   //上一章
    EpunControlProgressBtnTypeNext
};


@interface EpubControlProgressBar : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, copy) void (^chooseChapter)(EpunControlProgressBtnType type);
@property (nonatomic, copy) void (^chooseProgress)(CGFloat progress);

@end
