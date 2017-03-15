
#import "EpubDefaultUtil.h"

NSString * const Epub_NightModeChanged = @"Epub_NightModeChanged";
NSString * const Epub_FontChanged = @"Epub_FontChanged";

static NSString *Epub_IsNightMode = @"Epub_IsNightMode";
static NSString *Epub_DayNightColor = @"Epub_DayNightColor";
static NSString *Epub_ReadFont = @"Epub_ReadFont";
static NSString *Epub_ReadTextColor = @"Epub_ReadTextColor";

@implementation EpubDefaultUtil

+ (void)setIsNightMode:(BOOL)isNightMode{
    [[NSUserDefaults standardUserDefaults] setBool:isNightMode forKey:Epub_IsNightMode];
}

+ (BOOL)isNightMode{
    return [[NSUserDefaults standardUserDefaults] boolForKey:Epub_IsNightMode];
}

+ (void)setDayNightColor:(UIColor *)color{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:Epub_DayNightColor];
}

+ (UIColor *)dayNightColor{
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:Epub_DayNightColor];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}

+ (void)setReadFont:(UIFont *)font{
    NSData *fontData = [NSKeyedArchiver archivedDataWithRootObject:font];
    [[NSUserDefaults standardUserDefaults] setObject:fontData forKey:Epub_ReadFont];
}

+ (UIFont *)readFont{
    NSData *fontData = [[NSUserDefaults standardUserDefaults] objectForKey:Epub_ReadFont];
    return [NSKeyedUnarchiver unarchiveObjectWithData:fontData];
}

+ (void)setReadTextColor:(UIColor *)textColor{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:Epub_ReadTextColor];
}

+ (UIColor *)readTextColor{
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:Epub_ReadTextColor];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}


@end
