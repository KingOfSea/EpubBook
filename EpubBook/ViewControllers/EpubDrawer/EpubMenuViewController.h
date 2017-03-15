
#import <UIKit/UIKit.h>
#import "EpubParser.h"
#import "EpubDataBase.h"

#define E_UNAVAILABLE_INSTEAD(design) __attribute__((unavailable(design)))

@interface EpubMenuViewController : UIViewController

- (instancetype)initWithBookModel:(EpubBookModel *)bookModel epubParser:(EpubParser *)epubParser;

- (instancetype)init E_UNAVAILABLE_INSTEAD("use initWithBookModel:catalog: instead");

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil E_UNAVAILABLE_INSTEAD("use initWithBookModel:catalog: instead");

@property (nonatomic, strong, readonly) EpubBookModel *bookModel;
@property (nonatomic, strong, readonly) EpubParser *epubParser;

@property (nonatomic, copy) void (^catalogClick)(EpubChapter *chapter);

@property (nonatomic, copy) void (^markClick)(EpubMarkModel *mark);

@end
