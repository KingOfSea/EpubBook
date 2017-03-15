
#import "EpubReadStyle.h"

@implementation EpubReadStyle

+ (instancetype)sharedInstance{
    static EpubReadStyle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc]init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width-32;
        CGFloat height = [UIScreen mainScreen].bounds.size.height-80;
        self.showSize = CGSizeMake(width, height);
        self.font = [UIFont systemFontOfSize:17];
        self.textColor = [UIColor blackColor];
        self.linkColor = [UIColor blueColor];
    }
    return self;
}

+ (BOOL)isSameFont:(UIFont *)font color:(UIColor *)color{
    
    BOOL isSameFont = (font == [EpubReadStyle sharedInstance].font);
    BOOL isSameColor = (color == [EpubReadStyle sharedInstance].textColor);
    return isSameFont&&isSameColor;
}

+ (NSDictionary *)attributesForTitle{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.paragraphSpacing = 6;
    [paragraphStyle setLineSpacing:5];
    
    //    paragraphStyle.firstLineHeadIndent = readStyle.font.pointSize*2+3;
    return @{
             NSForegroundColorAttributeName:[EpubReadStyle sharedInstance].textColor,
             NSFontAttributeName:[UIFont boldSystemFontOfSize:[EpubReadStyle sharedInstance].font.pointSize+4],
             NSKernAttributeName:@(1.5),
             NSParagraphStyleAttributeName:paragraphStyle
             };
}

+ (NSDictionary *)attributesForContent{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 5;
    [paragraphStyle setLineSpacing:4];
    paragraphStyle.firstLineHeadIndent = [EpubReadStyle sharedInstance].font.pointSize*2+3;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    return @{
             NSForegroundColorAttributeName:[EpubReadStyle sharedInstance].textColor,
             NSFontAttributeName:[EpubReadStyle sharedInstance].font,
             NSKernAttributeName:@(1.5),
             NSParagraphStyleAttributeName:paragraphStyle
             };
}

+ (NSDictionary *)attributesForLink{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 5;
    [paragraphStyle setLineSpacing:4];
    paragraphStyle.firstLineHeadIndent = [EpubReadStyle sharedInstance].font.pointSize*2+3;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    return @{
             NSForegroundColorAttributeName:[EpubReadStyle sharedInstance].linkColor,
             NSFontAttributeName:[EpubReadStyle sharedInstance].font,
             NSKernAttributeName:@(1.5),
             NSParagraphStyleAttributeName:paragraphStyle,
             NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
             };
}

@end
