
#import <UIKit/UIKit.h>
#import "EpubDataBase.h"
@interface EpubDrawerMindCell : UITableViewCell

@property (nonatomic, strong) EpubMarkModel *markModel;

- (CGFloat)heightWithEpubMarkModel:(EpubMarkModel *)markModel;

@end
