
#import <UIKit/UIKit.h>
#import "EpubBadgeModel.h"
#import "EpubParser.h"
@interface EpubView : UIView

@property (nonatomic, strong) EpubPage *epubPage;

/**
 根据返回的index，判断EpubView是否可以响应单击
 */
@property (nonatomic, copy) BOOL (^singleClick)(NSInteger index, EpubView *epubView);

/**
 长按事件

 @param doing 未松开时的处理事件
 @param done 松开后的处理事件
 */
- (void)longPressDoing:(void(^)(CFRange range, EpubView *epubView))doing
                  done:(void(^)(CFRange range, EpubView *epubView))done;

/**
 底部下划线

 @param range 需要划线的区域
 */
- (void)drawBottomLineWithRange:(CFRange)range;

- (void)drawAllLinesWithSelectRanges:(NSArray *)selectRanges badges:(NSArray *)badges;

@end
