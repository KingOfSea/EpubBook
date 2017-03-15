
#import <Foundation/Foundation.h>
#import "EpubReadStyle.h"
#import <CoreText/CoreText.h>
//#import "EpubBurster.h"

@class EpubCatalog;
@class EpubImageInfo;
@class EpubPage;
@class EpubChapter;
@class EpubContent;

@interface EpubPage : NSObject
@property (nonatomic, weak) EpubContent *epubContent;
@property (nonatomic, assign) NSInteger currentPage;//当页所在的页数
@property (nonatomic, assign) NSRange range;//当页内容在整篇文章中的所在位置
@property (nonatomic, assign) CTFrameRef frameRef;//当页的显示内容
@property (nonatomic, copy) NSAttributedString *attributeText;//当页的文本内容
@property (nonatomic, strong, readonly) NSMutableArray<EpubImageInfo *> *images;//当页的所有图片

@property (nonatomic, weak) EpubPage *lastPage;
@property (nonatomic, weak) EpubPage *nextPage;

@end

@interface EpubLinkInfo : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *redirectionURL;//重定向地址

@end

@interface EpubTitleInfo : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSInteger size;//暂时没用，保留字段，若是h1，size为1，以此类推

@end

/**
 ImageInfo图片信息，图片的名称，以及图片在整个NSMutableAttributedString中的位置
 */
@interface EpubImageInfo : NSObject

@property (nonatomic, readonly, assign) CGSize imageSize;
@property (nonatomic, copy) NSString *filePath;//文件名称
@property (nonatomic, assign) NSInteger location;//文件位置
@property (nonatomic, assign) CGRect imgFrame;//图片绘制位置

@end

/**
 内容模型
 */
@interface EpubContent : NSObject

@property (nonatomic, weak) EpubChapter *epubChapter;
@property (nonatomic, copy) NSString *title;

+ (instancetype)epubContentWithEpubChapter:(EpubChapter *)epubChapter;
- (NSString *)content;
- (NSAttributedString *)attributedText;
- (NSArray<EpubImageInfo *> *)images;
- (NSArray<EpubTitleInfo *> *)titles;//h1-h6
- (NSArray<EpubLinkInfo *> *)links;
- (NSArray<EpubPage *> *)pages;

@end

/**
 目录节点模型(章节)
 */

@interface EpubChapter : NSObject

@property (nonatomic, copy) NSString *contentPath;
@property (nonatomic, copy) NSString *contentPathId;
@property (nonatomic, assign) NSInteger playOrder;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) EpubContent *epubContent;

//层级索引
@property (nonatomic, weak) EpubChapter *parentChapter;//父节点
@property (nonatomic, strong) NSArray<EpubChapter *> *subchapters;
@property (nonatomic, assign) NSInteger hierarchy;//所在层级

//顺序索引
@property (nonatomic, weak) EpubChapter *lastChapter;//上一章
@property (nonatomic, weak) EpubChapter *nextChapter;//下一章

@property (nonatomic, weak) EpubCatalog *epubCatalog;//索引

- (EpubContent *)parseEpubContent;

@property (nonatomic, assign) NSRange rangeInTotal;//在全文所属的range

@end

/**
 epub电子书目录模型
 */
@interface EpubCatalog : NSObject

@property (nonatomic, copy) NSString *rootPath;
@property (nonatomic, copy) NSString *opfPath;
@property (nonatomic, copy) NSString *ncxPath;

@property (nonatomic, copy) NSString *bookName;
@property (nonatomic, copy) NSString *bookAuthor;

@property (nonatomic, copy) NSArray<EpubChapter *> *menifestItems;//所有文件
@property (nonatomic, copy) NSArray<EpubChapter *> *directory_trees;//目录树
@property (nonatomic, copy) NSArray<EpubChapter *> *chapters_order;//有目录名称的章节
@property (nonatomic, copy) NSArray<EpubChapter *> *chapters;//顺序的章节
@property (nonatomic, copy) NSDictionary *pathDictionary;//根据地址查章节

@property (nonatomic, assign) NSInteger totalLength;//总长度

@end


/**
 EpubParser解析器，解析epub目录、顺序和html文件的内容
 */
//@class EpubBurster;
@interface EpubParser : NSObject
@property (nonatomic, strong, readonly) EpubCatalog *epubCatalog;

- (EpubCatalog *)parseToCatalogWithRootPath:(NSString *)rootPath;

/**
 解析文章总字数

 @param completion 完成回调
 */
- (void)parseProgressCompletion:(void(^)(NSInteger totalLength))completion;

//获取container.xml中的.opf路径
- (NSString *)getOpfPathWithRootPath:(NSString *)rootPath;

@end
