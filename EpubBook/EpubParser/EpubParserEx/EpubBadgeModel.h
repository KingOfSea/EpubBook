
#import <Foundation/Foundation.h>
@import CoreGraphics;
#import "EpubParser.h"
@interface EpubBadgeModel : NSObject

@property (nonatomic, strong) EpubPage *epubPage;
@property (nonatomic, copy) NSArray *mindModels;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, assign) NSInteger paragraph;
@property (nonatomic, assign) BOOL isContainedMyMind;//是否包含自己的想法

@end
