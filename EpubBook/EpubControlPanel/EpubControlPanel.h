
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EpubControlPanelType) {
    EpubControlPanelTypeMenu = 0,   //菜单
    EpubControlPanelTypeProgress,   //进度
    EpubControlPanelTypeDaynight,   //夜间模式
    EpubControlPanelTypeFont        //字体
};


@interface EpubControlPanel : UIView

@property (nonatomic, copy) void (^panelClick)(EpubControlPanelType type);

@end
