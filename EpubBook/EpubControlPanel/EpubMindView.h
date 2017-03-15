

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EpubMindViewAction) {
    EpubMindViewActionCopy = 0, //复制
    EpubMindViewActionMind,     //想法
    EpubMindViewActionShare,    //分享
    EpubMindViewActionDelete    //举报
};

extern NSString * const EpubMindViewColorChanged;

@interface EpubMindView : UIView

@property (nonatomic, copy) UIColor *lineColor;
@property (nonatomic, copy) void(^actionHandle)(EpubMindViewAction action);

+ (EpubMindView *)mindView;

@end
