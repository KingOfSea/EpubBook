
#import <Foundation/Foundation.h>
#import "EpubDataBase.h"
#import "EpubBadgeModel.h"





@interface EpubViewModel : NSObject

+ (NSString *)chapterIdWithEpubChapter:(EpubChapter *)epubChapter epubBookModel:(EpubBookModel *)epubBookModel;

+ (EpubChapter *)getChapterWithLinkInfo:(EpubLinkInfo *)linkInfo epubCatalog:(EpubCatalog *)epubCatalog;

/**
 获取页面相关想法

 @param epubPage 对应epubPage
 @param epubBookModel 对应图书model
 @param completion 完成回调
 */
+ (void)getRalativeMindModelsInEpubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel completion:(void(^)(NSArray *relativeMarkModels, NSArray *relativeRanges))completion;

+ (void)getRalativeLinkInfosInEpubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel completion:(void(^)(NSArray *relativeLinks))completion;

+ (void)setSelectedRangeWithRange:(NSRange)range mindModels:(NSArray *)mindModels epubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel;

+ (BOOL)addBookMarkWithRange:(NSRange)range epubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel;

+ (void)getBadgesWithMarkModels:(NSArray *)markModels
                       epubPage:(EpubPage *)epubPage
                  epubBookModel:bookModel
                     completion:(void(^)(NSArray *badges))completion;
#pragma mark -根据用户手指的坐标获得 手指下面文字在整页文字中的index
+ (CFIndex)getTouchIndexWithTouchPoint:(CGPoint)touchPoint epubPage:(EpubPage *)epubPage;

@end
