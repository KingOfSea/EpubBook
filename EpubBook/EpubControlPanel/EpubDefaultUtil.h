
#import <UIKit/UIKit.h>
#import "NSNotificationCenter+Add.h"

#define EpubReadDayColor [UIColor colorWithWhite:218/255.0 alpha:1]
#define EpubReadNightColor [UIColor colorWithWhite:43/255.0 alpha:1]
#define EpubReadDayTextColor [UIColor colorWithWhite:50/255.0 alpha:1]
#define EpubReadNightTextColor [UIColor colorWithWhite:160/255.0 alpha:1]
#define EpubReadDayLinkColor [UIColor blueColor]
#define EpubReadNightLinkColor [UIColor colorWithRed:87/255.0 green:87/255.0 blue:0 alpha:1]
#define EpubReadNightViewColor [UIColor colorWithWhite:20/255.0 alpha:1]
#define EpubReadDayViewColor [UIColor colorWithWhite:228/255.0 alpha:1]
#define EpubReadNightNavColor [UIColor colorWithRed:77/255.0 green:123/255.0 blue:113/255.0 alpha:1]
#define EpubReadDayNavColor [UIColor colorWithRed:147/255.0 green:193/255.0 blue:183/255.0 alpha:1]

extern NSString * const Epub_NightModeChanged;//夜间模式的改变
extern NSString * const Epub_FontChanged;//字体改变通知

@interface EpubDefaultUtil : NSObject

+ (void)setIsNightMode:(BOOL)isNightMode;
+ (BOOL)isNightMode;

+ (void)setDayNightColor:(UIColor *)color;
+ (UIColor *)dayNightColor;

+ (void)setReadFont:(UIFont *)font;
+ (UIFont *)readFont;

+ (void)setReadTextColor:(UIColor *)textColor;
+ (UIColor *)readTextColor;

@end
