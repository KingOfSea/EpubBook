
#import "NSMutableAttributedString+Add.h"

@implementation NSMutableAttributedString (Add)

- (void)removeAttributes:(NSArray *)names range:(NSRange)range{
    for (NSString *name in names) {
        [self removeAttribute:name range:range];
    }
}

@end
