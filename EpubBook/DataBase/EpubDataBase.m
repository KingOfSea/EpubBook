
#import "EpubDataBase.h"
#import "FMDB.h"
#import "FileManagerUtil.h"

NSString * const EpubDataBaseMarkTableUpdate = @"EpubDataBaseMarkTableUpdate";
NSString * const EpubDataBaseBookTableUpdate = @"EpubDataBaseBookTableUpdate";
NSString * const EpubDataBaseMarkTableDelete = @"EpubDataBaseMarkTableDelete";


static NSString *table_mark         = @"TABLE_MARK";    //书签列表

static NSString *mark_id            = @"MARK_ID";       //标记ID
static NSString *user_id            = @"USER_ID";       //用户ID
static NSString *user_name          = @"USER_NAME";     //用户名称
static NSString *chapter_id         = @"CHAPTER_ID";    //文章ID，MD5(路径)获得
static NSString *chapter_name       = @"CHAPTER_NAME";  //文章名称
static NSString *chapter_order      = @"CHAPTER_ORDER"; //文章的顺序
static NSString *chapter_paragraph  = @"CHAPTER_PARAGRAPH"; //所在的段落
static NSString *index_start        = @"INDEX_START";   //起始位置
static NSString *index_end          = @"INDEX_END";     //终止位置
static NSString *mark_content       = @"MARK_CONTENT";  //标记内容
static NSString *mark_type          = @"MARK_TYPE";     //0想法，1书签
static NSString *mark_info          = @"MARK_INFO";     //用户想法，mark_type为1时为空
static NSString *mark_timeStamp     = @"MARK_TIMESTAMP";//时间戳


static NSString *table_book         = @"TABLE_BOOK";    //图书列表
static NSString *book_id            = @"BOOK_ID";       //图书ID
static NSString *book_name          = @"BOOK_NAME";     //书名
static NSString *book_isbuy         = @"BOOK_ISBUY";    //是否已购买
static NSString *book_curchap       = @"BOOK_CURCHAP";  //当前章节
static NSString *book_curindex      = @"BOOK_CURINDEX"; //当前章节的index
static NSString *book_freechaps     = @"BOOK_FREECHAPS";//免费章节数
static NSString *book_lasttime      = @"BOOK_LASTTIME"; //上次修改时间
static NSString *book_isdownload    = @"BOOK_DOWNLOAD"; //是否已经下载


@interface EpubBookModel()
@property (nonatomic, copy) NSArray *sqlValues;
@end

@implementation EpubBookModel
- (NSArray *)sqlValues{
    return @[
             EpubValidString(_bookId),
             EpubValidString(_bookName),
             EpubStringFromInteger(_currentChapter),
             EpubStringFromInteger(_currentIndex),
             EpubStringFromBool(_isBuy),
             EpubStringFromInteger(_freeChapNum),
             EpubValidString(_lastTime),
             EpubStringFromBool(_isDownloaded)
             ];
}
@end

@interface EpubMarkModel()
@property (nonatomic, copy) NSArray *sqlValues;
@end

@implementation EpubMarkModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

- (NSArray *)sqlValues{
    _timeStamp = [[NSDate date] timeIntervalSince1970];
    return @[
             EpubValidString(_markId),
             GetUserInfo(USER_ID),
             GetUserInfo(USER_NAME),
             EpubValidString(_bookId),
//             EpubValidString(_bookName),
             EpubValidString(_chapterId),
             EpubValidString(_chapterName),
             EpubStringFromInteger(_playOrder),
             EpubStringFromInteger(_paragraph),
             EpubStringFromInteger(_indexStart),
             EpubStringFromInteger(_indexEnd),
             EpubValidString(_markContent),
             EpubValidString(_markInfo),
             EpubStringFromInteger(_markType),
             EpubStringFromDouble(_timeStamp)
             ];
}

@end


static EpubDataBase * sharedInstance;

@interface EpubDataBase ()
@property (nonatomic, strong) FMDatabaseQueue * dbQueue;

@end

@implementation EpubDataBase


+ (EpubDataBase *)dateBase{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * filePath = [NSString stringWithFormat:@"Documents/EpubSDK/epubDatabase.db"];
        filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
        [FileManagerUtil cycleCreateWithPath:filePath];
        sharedInstance = [[self alloc]initWithPath:filePath];
    });
    return sharedInstance;
}



- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
        [self openBookTable];
        [self openMarkTable];
    }
    return self;
}

- (void)openBookTable{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        NSString *sqlStr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text)",
                            table_book,
                            book_id,
                            book_name,
                            book_curchap,
                            book_curindex,
                            book_isbuy,
                            book_freechaps,
                            book_lasttime,
                            book_isdownload
                            ];
        if (![self isExistedWithDataBase:db Table:table_mark]){
            [db executeUpdate:sqlStr];
        }
//        [self reloadDownloadTableWithDataBase:db];
    }];
}

- (void)reloadDownloadTableWithDataBase:(FMDatabase *)db{
    
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@",table_book];
    FMResultSet * rs = [db executeQuery:query];
    
    while ([rs next]) {
        NSString *bookId = [rs stringForColumn:book_id];
        BOOL isDownloaded = [rs boolForColumn:book_isdownload];
        NSString *filePath = [NSString stringWithFormat:@"Documents/books/%@.epub",bookId];
        filePath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (!fileData.length||!isDownloaded) {
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
            NSString * query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '0' WHERE %@ = '%@'",table_book,book_isdownload,book_id,bookId];
            [db executeUpdate:query];
        }
    }
    [rs close];
}

//创建下载表
- (void)openMarkTable
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        NSString *sqlStr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text)",
                            table_mark,
                            mark_id,
                            user_id,
                            user_name,
                            book_id,
//                            book_name,
                            chapter_id,
                            chapter_name,
                            chapter_order,
                            chapter_paragraph,
                            index_start,
                            index_end,
                            mark_content,
                            mark_info,
                            mark_type,
                            mark_timeStamp];
        if (![self isExistedWithDataBase:db Table:table_mark]){
            [db executeUpdate:sqlStr];
        }
    }];
}


//监测数据库中需要的表是否已经存在
- (BOOL)isExistedWithDataBase:(FMDatabase *)db Table:(NSString *)table{
    BOOL isExisted = NO;
    NSString *existsSql = [NSString stringWithFormat:@"select count(name) as countNum from sqlite_master where type ='table' and name = '%@'", table];
    FMResultSet *rs = [db executeQuery:existsSql];
    isExisted = ([rs next]&&[rs intForColumn:@"countNum"]==1)?YES:NO;//intForColumn 获取整形字段的信息
    [rs close];
    return isExisted;
}

+ (BOOL)insertBookWithBookModel:(EpubBookModel *)bookModel{
    EpubDataBase *dataBase = [self dateBase];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(?,?,?,?,?,?,?,?)",table_book];
    __block BOOL result = NO;
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        //判断有无重复任务
        NSString *bookId = bookModel.bookId;
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",table_book,book_id,bookId];
        FMResultSet * rs = [db executeQuery:query];
        if (![rs next]) {
            //没有的话，插入
            result = [db executeUpdate:sql values:bookModel.sqlValues error:nil];
        };
        [rs close];
    }];
    return result;
}

+ (BOOL)insertMarkWithMarkModel:(EpubMarkModel *)markModel{
    EpubDataBase *dataBase = [self dateBase];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",table_mark];
    __block BOOL result = NO;
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        //判断有无重复任务
        NSString *markId = markModel.markId;
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@'",table_mark,book_id,markId,user_id,GetUserInfo(USER_ID)];
        FMResultSet * rs = [db executeQuery:query];
        if (![rs next]) {
            //没有的话，插入
            result = [db executeUpdate:sql values:markModel.sqlValues error:nil];
        };
        [rs close];
    }];
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EpubDataBaseMarkTableUpdate object:nil userInfo:@{@"MarkModel":markModel}];
    }
    return result;
}

+ (BOOL)deleteBookWithBookModel:(EpubBookModel *)bookModel{
    EpubDataBase *dataBase = [self dateBase];
    __block BOOL result = NO;
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",table_book,book_id,bookModel.bookId];
        
        //删除表中的数据
        query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",table_book,book_id,bookModel.bookId];
        result = [db executeUpdate:query];
        
    }];
    return result;
}

+ (BOOL)deleteMarkWithMarkModel:(EpubMarkModel *)markModel{
    EpubDataBase *dataBase = [self dateBase];
    __block BOOL result = NO;
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        //删除表中的数据
        NSString *query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@' AND %@ = '%@'",table_mark,mark_id,markModel.markId,user_id,GetUserInfo(USER_ID)];
        result = [db executeUpdate:query];
    }];
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EpubDataBaseMarkTableDelete object:nil userInfo:@{@"MarkModel":markModel}];
    }
    return result;
}

+ (BOOL)updateBookWithBookModel:(EpubBookModel *)bookModel{
    __block BOOL result = NO;
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        NSString * query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@' WHERE %@ = '%@'",
                            table_book,
                            book_curchap,EpubStringFromInteger(bookModel.currentChapter),
                            book_name,EpubValidString(bookModel.bookName),
                            book_isbuy,EpubStringFromBool(bookModel.isBuy),
                            book_curindex,EpubStringFromInteger(bookModel.currentIndex),
                            book_freechaps,EpubStringFromInteger(bookModel.freeChapNum),
                            book_lasttime,bookModel.lastTime,
                            book_isdownload,EpubStringFromBool(bookModel.isDownloaded),
                            book_id,bookModel.bookId
                            ];
        result = [db executeUpdate:query];
    }];
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EpubDataBaseBookTableUpdate object:nil userInfo:@{@"CurrentChapter":@(bookModel.currentChapter)}];
    }
    return result;
}

+ (BOOL)updateMarkWithMarkModel:(EpubMarkModel *)markModel{
    __block BOOL result = NO;
    markModel.timeStamp = [[NSDate date] timeIntervalSince1970];
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        NSString * query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@',%@ = '%@' WHERE %@ = '%@'",
                            table_mark,
                            user_name,markModel.userName,
                            book_id,markModel.bookId,
//                            book_name,markModel.bookName,
                            chapter_id,markModel.chapterId,
                            chapter_paragraph,EpubStringFromInteger(markModel.paragraph),
                            index_start,EpubStringFromInteger(markModel.indexStart),
                            index_end,EpubStringFromInteger(markModel.indexEnd),
                            mark_content,markModel.markContent,
                            mark_info,markModel.markInfo,
                            mark_type,EpubStringFromInteger(markModel.markType),
                            mark_timeStamp,EpubStringFromDouble(markModel.timeStamp),
                            mark_id,markModel.markId
                            ];
        result = [db executeUpdate:query];
    }];
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EpubDataBaseMarkTableUpdate object:nil userInfo:@{@"MarkModel":markModel}];
    }
    return result;
}

+ (NSArray<EpubBookModel *> *)getAllbooks{
    NSMutableArray * mutableArr = [NSMutableArray array];
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC",table_book,book_lasttime];
        
        FMResultSet * rs = [db executeQuery:query];
        while ([rs next]) {
            EpubBookModel *bookModel = [[EpubBookModel alloc]init];
            
            bookModel.bookId            = [rs stringForColumn:book_id];
            bookModel.bookName          = [rs stringForColumn:book_name];
            bookModel.currentChapter    = [rs longLongIntForColumn:book_curchap];
            bookModel.currentIndex      = [rs longLongIntForColumn:book_curindex];
            bookModel.isBuy             = [rs boolForColumn:book_isbuy];
            bookModel.freeChapNum       = [rs longLongIntForColumn:book_freechaps];
            bookModel.lastTime          = [rs stringForColumn:book_lasttime];
            bookModel.isDownloaded      = [rs boolForColumn:book_isdownload];
            [mutableArr addObject:bookModel];
        }
        [rs close];
    }];
    return [mutableArr copy];
}

+ (EpubBookModel *)bookModelWithBookId:(NSString *)bookId{
    __block EpubBookModel *model = nil;
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",table_book,book_id,bookId];
        
        FMResultSet * rs = [db executeQuery:query];
        if ([rs next]) {
            EpubBookModel *bookModel = [[EpubBookModel alloc]init];
            
            bookModel.bookId            = [rs stringForColumn:book_id];
            bookModel.bookName          = [rs stringForColumn:book_name];
            bookModel.currentChapter    = [rs longLongIntForColumn:book_curchap];
            bookModel.currentIndex      = [rs longLongIntForColumn:book_curindex];
            bookModel.isBuy             = [rs boolForColumn:book_isbuy];
            bookModel.freeChapNum       = [rs longLongIntForColumn:book_freechaps];
            bookModel.lastTime          = [rs stringForColumn:book_lasttime];
            bookModel.isDownloaded      = [rs boolForColumn:book_isdownload];
            model = bookModel;
        }
        [rs close];
    }];
    return model;
}

+ (NSArray<EpubMarkModel *> *)marksForBookModel:(EpubBookModel *)bookModel type:(EpubMarkType)type{
    NSMutableArray * mutableArr = [NSMutableArray array];
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = '%@' ORDER BY %@ DESC",
                            table_mark,
                            book_id,bookModel.bookId,
                            mark_type,EpubStringFromInteger(type),
                            user_id,GetUserInfo(USER_ID),
                            mark_timeStamp];
        
        FMResultSet * rs = [db executeQuery:query];
        while ([rs next]) {
            
            EpubMarkModel *markModel = [[EpubMarkModel alloc]init];
            
            markModel.markId        = [rs stringForColumn:mark_id];
            markModel.userId        = [rs stringForColumn:user_id];
            markModel.userName        = [rs stringForColumn:user_name];
            markModel.bookId        = [rs stringForColumn:book_id];
//            markModel.bookName      = [rs stringForColumn:book_name];
            markModel.chapterId     = [rs stringForColumn:chapter_id];
            markModel.chapterName   = [rs stringForColumn:chapter_name];
            markModel.playOrder     = [rs longLongIntForColumn:chapter_order];
            markModel.paragraph     = [rs longLongIntForColumn:chapter_paragraph];
            markModel.indexStart    = [rs longLongIntForColumn:index_start];
            markModel.indexEnd      = [rs longLongIntForColumn:index_end];
            markModel.markContent   = [rs stringForColumn:mark_content];
            markModel.markInfo      = [rs stringForColumn:mark_info];
            markModel.markType      = [rs longLongIntForColumn:mark_type];
            markModel.timeStamp     = [rs doubleForColumn:mark_timeStamp];
            [mutableArr addObject:markModel];
        }
        [rs close];
    }];
    return [mutableArr copy];
}

+ (NSArray<EpubMarkModel *> *)marksForBookModel:(EpubBookModel *)bookModel playOrder:(NSInteger)playOrder type:(EpubMarkType)type{
    NSMutableArray * mutableArr = [NSMutableArray array];
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = '%@' AND %@ = '%@' ORDER BY %@ DESC",
                            table_mark,
                            book_id,bookModel.bookId,
                            mark_type,EpubStringFromInteger(type),
                            chapter_order,EpubStringFromInteger(playOrder),
                            user_id,GetUserInfo(USER_ID),
                            mark_timeStamp];
        
        FMResultSet * rs = [db executeQuery:query];
        while ([rs next]) {
            
            EpubMarkModel *markModel = [[EpubMarkModel alloc]init];
            
            markModel.markId        = [rs stringForColumn:mark_id];
            markModel.userId        = [rs stringForColumn:user_id];
            markModel.userName        = [rs stringForColumn:user_name];
            markModel.bookId        = [rs stringForColumn:book_id];
            //            markModel.bookName      = [rs stringForColumn:book_name];
            markModel.chapterId     = [rs stringForColumn:chapter_id];
            markModel.chapterName   = [rs stringForColumn:chapter_name];
            markModel.playOrder     = [rs longLongIntForColumn:chapter_order];
            markModel.paragraph     = [rs longLongIntForColumn:chapter_paragraph];
            markModel.indexStart    = [rs longLongIntForColumn:index_start];
            markModel.indexEnd      = [rs longLongIntForColumn:index_end];
            markModel.markContent   = [rs stringForColumn:mark_content];
            markModel.markInfo      = [rs stringForColumn:mark_info];
            markModel.markType      = [rs longLongIntForColumn:mark_type];
            markModel.timeStamp     = [rs doubleForColumn:mark_timeStamp];
            [mutableArr addObject:markModel];
        }
        [rs close];
    }];
    return [mutableArr copy];
}

+ (NSArray<EpubMarkModel *> *)marksForChapterId:(NSString *)chapterId type:(EpubMarkType)type{
    //获取文章ID
//    NSString *chapterId = chapterId;
    NSMutableArray * mutableArr = [NSMutableArray array];
    EpubDataBase *dataBase = [self dateBase];
    [dataBase.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@' AND %@ = '%@' AND %@ = '%@' ORDER BY %@ ASC",
                            table_mark,
                            chapter_id,chapterId,
                            mark_type,EpubStringFromInteger(type),
                            user_id,GetUserInfo(USER_ID),
                            index_start];
        
        FMResultSet * rs = [db executeQuery:query];
        while ([rs next]) {
            
            EpubMarkModel *markModel = [[EpubMarkModel alloc]init];
            
            markModel.markId        = [rs stringForColumn:mark_id];
            markModel.userId        = [rs stringForColumn:user_id];
            markModel.userName        = [rs stringForColumn:user_name];
            markModel.bookId        = [rs stringForColumn:book_id];
//            markModel.bookName      = [rs stringForColumn:book_name];
            markModel.chapterId     = [rs stringForColumn:chapter_id];
            markModel.chapterName   = [rs stringForColumn:chapter_name];
            markModel.playOrder     = [rs longLongIntForColumn:chapter_order];
            markModel.paragraph     = [rs longLongIntForColumn:chapter_paragraph];
            markModel.indexStart    = [rs longLongIntForColumn:index_start];
            markModel.indexEnd      = [rs longLongIntForColumn:index_end];
            markModel.markContent   = [rs stringForColumn:mark_content];
            markModel.markInfo      = [rs stringForColumn:mark_info];
            markModel.markType      = [rs longLongIntForColumn:mark_type];
            markModel.timeStamp     = [rs doubleForColumn:mark_timeStamp];
            [mutableArr addObject:markModel];
        }
        [rs close];
    }];
    return [mutableArr copy];
}
@end
