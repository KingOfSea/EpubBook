
#import <Foundation/Foundation.h>

#define EpubValidString(string) ({\
NSString *tempString = @"";\
if ([string isKindOfClass:[NSString class]]&&string.length!=0) {\
tempString = string;\
}\
tempString;\
})

#define EpubStringFromInteger(integer) [NSString stringWithFormat:@"%ld",integer]
#define EpubStringFromBool(bool) [NSString stringWithFormat:@"%i",bool]
#define EpubStringFromDouble(double) [NSString stringWithFormat:@"%f",double]

#define GetUserInfo(USER_ID) @"XXXXXX"

extern NSString * const EpubDataBaseMarkTableUpdate;//MarkTable更新通知
extern NSString * const EpubDataBaseMarkTableDelete;//MarkTable删除通知
extern NSString * const EpubDataBaseBookTableUpdate;//BookTable更新通知

typedef NS_ENUM(NSInteger, EpubMarkType) {
    EpubMarkTypeMind = 0,   //想法
    EpubMarkTypeMark        //书签
};


@interface EpubBookModel : NSObject

@property (nonatomic, copy) NSString *bookId;
@property (nonatomic, copy) NSString *bookName;
@property (nonatomic, assign) BOOL isBuy;//是否已购买
@property (nonatomic, assign) NSInteger currentChapter;//当前阅读的章节数
@property (nonatomic, assign) NSInteger currentIndex;//当前阅读的章节数的index
@property (nonatomic, assign) NSInteger freeChapNum;//免费章节数
@property (nonatomic, copy) NSString *lastTime;//修改时间
@property (nonatomic, assign) BOOL isDownloaded;//是否已经下载


@end

@interface EpubMarkModel : NSObject

@property (nonatomic, copy) NSString *markId;//想法Id
@property (nonatomic, copy) NSString *markInfo;//想法
@property (nonatomic, copy) NSString *chapterId;//章节Id
@property (nonatomic, copy) NSString *chapterName;//章节名称
@property (nonatomic, assign) NSInteger playOrder;//章节顺序索引
@property (nonatomic, assign) NSInteger paragraph;//章节段落
@property (nonatomic, assign) NSInteger indexStart;//想法起始位置
@property (nonatomic, assign) NSInteger indexEnd;//想法结束位置
@property (nonatomic, copy) NSString *bookId;//书Id
@property (nonatomic, copy) NSString *userId;//读者ID
@property (nonatomic, copy) NSString *userName;//读者ID
@property (nonatomic, copy) NSString *markContent;//想法被标记的内容
@property (nonatomic, assign) EpubMarkType markType;

@property (nonatomic, assign) NSTimeInterval timeStamp;//时间戳

@property (nonatomic, copy) NSString *serveId;//服务器返回的Id

@end

@interface EpubDataBase : NSObject

+ (EpubDataBase *)dateBase;

/**
 添加一本新书
 */
+ (BOOL)insertBookWithBookModel:(EpubBookModel *)bookModel;

/**
 添加一个标签或想法
 */
+ (BOOL)insertMarkWithMarkModel:(EpubMarkModel *)markModel;

/**
 删除一本书
 */
+ (BOOL)deleteBookWithBookModel:(EpubBookModel *)bookModel;

/**
 删除一个标签或想法
 */
+ (BOOL)deleteMarkWithMarkModel:(EpubMarkModel *)markModel;

/**
 更改书的信息
 */
+ (BOOL)updateBookWithBookModel:(EpubBookModel *)bookModel;

/**
 更改一个书签
 */
+ (BOOL)updateMarkWithMarkModel:(EpubMarkModel *)markModel;

/**
 获取所有图书
 */
+ (NSArray<EpubBookModel *> *)getAllbooks;

+ (EpubBookModel *)bookModelWithBookId:(NSString *)bookId;

/**
 获取该书所有的书签或想法
 */
+ (NSArray<EpubMarkModel *> *)marksForBookModel:(EpubBookModel *)bookModel type:(EpubMarkType)type;

+ (NSArray<EpubMarkModel *> *)marksForBookModel:(EpubBookModel *)bookModel playOrder:(NSInteger)playOrder type:(EpubMarkType)type;

/**
 获取该路径下文件所有的书签或想法
 */
+ (NSArray<EpubMarkModel *> *)marksForChapterId:(NSString *)chapterId type:(EpubMarkType)type;


@end
