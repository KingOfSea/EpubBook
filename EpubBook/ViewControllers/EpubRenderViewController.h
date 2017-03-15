
#import <UIKit/UIKit.h>
#import "EpubView.h"
#import "EpubDataBase.h"

extern NSString * const EpubMarkChoosed;

@interface EpubRenderViewController : UIViewController

@property (nonatomic, strong, readonly) EpubView *epubView;
@property (nonatomic, strong, readonly) EpubPage *epubPage;
@property (nonatomic, strong, readonly) EpubBookModel *bookModel;

- (instancetype)initWithEpubPage:(EpubPage *)epubPage EpubBookModel:(EpubBookModel *)bookModel;

@end
