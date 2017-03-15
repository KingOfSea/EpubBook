
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EpubReadStyle : NSObject

@property (nonatomic, strong) UIFont *font;//显示字体大小
@property (nonatomic, strong) UIColor *textColor;//显示字体颜色
@property (nonatomic, strong) UIColor *linkColor;//链接颜色
@property (nonatomic, strong) UIColor *bottomLineColor;//下划线颜色
@property (nonatomic, assign) CGSize showSize;//显示区域大小

+ (instancetype)sharedInstance;
+ (BOOL)isSameFont:(UIFont *)font color:(UIColor *)color;
+ (NSDictionary *)attributesForTitle;
+ (NSDictionary *)attributesForContent;
+ (NSDictionary *)attributesForLink;

@end
