
#import "EpubViewModel.h"
#import "NSString+MD5.h"
#import "CTFunction.h"

static dispatch_queue_t business_concurrent_queue(){
    static dispatch_queue_t epub_business_concurrent_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        epub_business_concurrent_queue = dispatch_queue_create("com.unknown.business.concurrent.creation", DISPATCH_QUEUE_CONCURRENT);
    });
    return epub_business_concurrent_queue;
}

__unused static dispatch_queue_t business_serial_queue(){
    static dispatch_queue_t epub_business_serial_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        epub_business_serial_queue = dispatch_queue_create("com.unknown.business.serial.creation", DISPATCH_QUEUE_SERIAL);
    });
    return epub_business_serial_queue;
}



@implementation EpubViewModel

+ (NSString *)chapterIdWithEpubChapter:(EpubChapter *)epubChapter epubBookModel:(EpubBookModel *)epubBookModel{
    NSString *bookId = epubBookModel.bookId;
    NSString *contentPathId = epubChapter.contentPathId;
    NSString *chapterId = [NSString stringWithFormat:@"EPUB_%@_%@",bookId,contentPathId];
    chapterId = [chapterId MD5_16NumString];
    return chapterId;
}

+ (NSString *)markIdWithEpubChapter:(EpubChapter *)epubChapter epubBookModel:(EpubBookModel *)epubBookModel{
    NSString *bookId = epubBookModel.bookId;
    NSString *contentPathId = epubChapter.contentPathId;
    NSString *markId = [NSString stringWithFormat:@"EPUB_%@_%@_%ld",bookId,contentPathId,(NSInteger)[[NSDate date] timeIntervalSince1970]];
    markId = [markId MD5_16NumString];
    return markId;
}

+ (NSString *)markContentWithEpubPage:(EpubPage *)epubPage range:(NSRange)range{
    NSString *content = epubPage.epubContent.content;
    content = [content substringWithRange:range];
    
    return [self stringWithContent:content epubPage:epubPage];
}

+ (NSString *)markContentWithEpubChapter:(EpubChapter *)epubChapter range:(NSRange)range{
    NSString *content = epubChapter.epubContent.content;
    content = [content substringWithRange:range];
    
    return [self stringWithContent:content epubChapter:epubChapter];
}

+ (EpubChapter *)getChapterWithLinkInfo:(EpubLinkInfo *)linkInfo epubCatalog:(EpubCatalog *)epubCatalog{
    
    NSString *key = [NSString stringWithFormat:@"%ld",linkInfo.redirectionURL.hash];
    EpubChapter *epubChapter = [epubCatalog.pathDictionary valueForKey:key];
    return epubChapter;
}

+ (NSArray *)getSelectedRangesWithEpubChapter:(EpubChapter *)epubChapter epubBookModel:(EpubBookModel *)epubBookModel{
    NSString *chapterId = [self chapterIdWithEpubChapter:epubChapter epubBookModel:epubBookModel];
    NSArray *selectedRanges = [EpubDataBase marksForChapterId:chapterId type:EpubMarkTypeMind];
    return selectedRanges;
}

+ (void)getRalativeMindModelsInEpubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel completion:(void(^)(NSArray *relativeMarkModels, NSArray *relativeRanges))completion{
    
    dispatch_async(business_concurrent_queue(), ^{
        NSArray *allMarkModels = [self getSelectedRangesWithEpubChapter:epubPage.epubContent.epubChapter epubBookModel:epubBookModel];
        NSMutableArray *relativeMarkModels = [NSMutableArray array];
        NSMutableArray *relativeRanges = [NSMutableArray array];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_apply(allMarkModels.count, business_concurrent_queue(), ^(size_t index) {
            EpubMarkModel *markModel = allMarkModels[index];
            NSRange markRange = NSMakeRange(markModel.indexStart, markModel.indexEnd-markModel.indexStart+1);
            NSRange insectionRange = NSRangeInsection(epubPage.range, markRange);
            if (!NSRangeEqualToRange(insectionRange, NSRangeZero)) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [relativeMarkModels addObject:markModel];
                [relativeRanges addObject:[NSValue valueWithRange:insectionRange]];
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion?:completion([relativeMarkModels copy],[relativeRanges copy]);
        });
    });
    
}

+ (void)getRalativeLinkInfosInEpubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel completion:(void (^)(NSArray *))completion{
    dispatch_async(business_concurrent_queue(), ^{
        NSArray *allLinkInfos = epubPage.epubContent.links;
        NSMutableArray *relativeLinks = [NSMutableArray array];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_apply(allLinkInfos.count, business_concurrent_queue(), ^(size_t index) {
            EpubLinkInfo *linkInfo = allLinkInfos[index];
            NSRange rangeOfLink = linkInfo.range;
            NSRange insectionRange = NSRangeInsection(epubPage.range, rangeOfLink);
            if (!NSRangeEqualToRange(insectionRange, NSRangeZero)) {
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [relativeLinks addObject:linkInfo];
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion?:completion([relativeLinks copy]);
        });
    });
}

+ (void)setSelectedRangeWithRange:(NSRange)range mindModels:(NSArray *)mindModels epubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel{
    
    dispatch_async(business_concurrent_queue(), ^{
        EpubMarkModel *newMark = [[EpubMarkModel alloc]init];
        NSString *markId = [self markIdWithEpubChapter:epubPage.epubContent.epubChapter epubBookModel:epubBookModel];
        NSString *chapterId = [self chapterIdWithEpubChapter:epubPage.epubContent.epubChapter epubBookModel:epubBookModel];
        newMark.markId = markId;
        newMark.bookId = epubBookModel.bookId;
        newMark.chapterId = chapterId;
        newMark.chapterName = epubPage.epubContent.epubChapter.title;
        newMark.indexStart = range.location;
        newMark.playOrder = epubPage.epubContent.epubChapter.playOrder;
        newMark.indexEnd = range.location+range.length-1;
        newMark.markType = EpubMarkTypeMind;
        
        NSMutableArray *influenceMarks = [NSMutableArray array];
        NSMutableArray *idArray = [NSMutableArray array];
        for (EpubMarkModel *markModel in mindModels) {
            NSRange markRange = NSMakeRangeWithInterval(markModel.indexStart, markModel.indexEnd);
            NSRange newMarkRange = NSMakeRangeWithInterval(newMark.indexStart, newMark.indexEnd);
            NSRange insectionRange = NSRangeInsection(markRange, newMarkRange);
            if(NSRangeEqualToRange(insectionRange, NSRangeZero)){
                continue;
            }
            newMark.indexStart = MIN(markModel.indexStart, newMark.indexStart);
            newMark.indexEnd = MAX(markModel.indexEnd, newMark.indexEnd);
            
            [influenceMarks addObject:markModel];
            [idArray addObject:markModel.markId];
        }
        
        
        
        NSRange newRange = NSMakeRangeWithInterval(newMark.indexStart, newMark.indexEnd);
        NSString *markContent = [self markContentWithEpubPage:epubPage range:newRange];
        NSMutableArray *markInfos = [NSMutableArray array];
        for (EpubMarkModel *markModel in influenceMarks) {
            if (markModel.markInfo.length) {
                [markInfos addObject:markModel.markInfo];
            }
            [EpubDataBase deleteMarkWithMarkModel:markModel];
        }
        newMark.markInfo = [markInfos componentsJoinedByString:@"\n"];
        newMark.markContent = markContent;
        newMark.paragraph = [self paragraphFromIndex:newMark.indexEnd epubPage:epubPage];
        [EpubDataBase insertMarkWithMarkModel:newMark];
    });
    
}

+ (BOOL)addBookMarkWithRange:(NSRange)range epubPage:(EpubPage *)epubPage epubBookModel:(EpubBookModel *)epubBookModel{
    EpubMarkModel *newMark = [[EpubMarkModel alloc]init];
    NSString *markId = [self markIdWithEpubChapter:epubPage.epubContent.epubChapter epubBookModel:epubBookModel];
    NSString *chapterId = [self chapterIdWithEpubChapter:epubPage.epubContent.epubChapter epubBookModel:epubBookModel];
    newMark.markId = markId;
    newMark.bookId = epubBookModel.bookId;
    newMark.chapterId = chapterId;
    newMark.chapterName = epubPage.epubContent.epubChapter.title;
    newMark.indexStart = range.location;
    newMark.playOrder = epubPage.epubContent.epubChapter.playOrder;
    newMark.indexEnd = range.location+range.length-1;
    newMark.markType = EpubMarkTypeMark;
    
    
    
    NSArray *allMarks = [EpubDataBase marksForBookModel:epubBookModel type:EpubMarkTypeMark];
    
    for (EpubMarkModel *markModel in allMarks) {
        BOOL isSameChapter = [markModel.chapterId isEqualToString:newMark.chapterId];
        BOOL isSameOrigin = markModel.indexStart == newMark.indexStart;
        if (isSameChapter&&isSameOrigin) {
            return NO;
        }
    }
    
    NSRange newRange = NSMakeRange(newMark.indexStart, newMark.indexEnd-newMark.indexStart+1);
    newMark.markContent = [self markContentWithEpubPage:epubPage range:newRange];;
    newMark.paragraph = [self paragraphFromIndex:newMark.indexEnd epubPage:epubPage];
    
    return [EpubDataBase insertMarkWithMarkModel:newMark];
}

#pragma mark - 处理书签内容

+ (NSString *)stringWithContent:(NSString *)content epubPage:(EpubPage *)epubPage{
    
    if ([content hasPrefix:@" \n"]) {
        if ([epubPage.images.firstObject location]==epubPage.range.location) {
            return [content stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"图片"];
        }
    }
    
    NSString *regexStr = @"^\n+";
    content = [content stringByReplacingOccurrencesOfString:regexStr withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, content.length)];
    return content;
}

+ (NSString *)stringWithContent:(NSString *)content epubChapter:(EpubChapter *)epubChapter{
    
    NSString *regexStr = @"^\n+";
    content = [content stringByReplacingOccurrencesOfString:regexStr withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, content.length)];
    return content;
}


#pragma mark -根据用户手指的坐标获得 手指下面文字在整页文字中的index
+ (CFIndex)getTouchIndexWithTouchPoint:(CGPoint)touchPoint epubPage:(EpubPage *)epubPage{
    touchPoint.x -= 16;
    touchPoint.y -= 40;
    CTFrameRef textFrame = epubPage.frameRef;
    NSArray *lines = (NSArray*)CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    CFIndex index = -1;
    NSInteger lineCount = [lines count];
    CGPoint *origins = (CGPoint*)malloc(lineCount * sizeof(CGPoint));
    if (lineCount != 0) {
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        for (int i = 0; i < lineCount; i++){
            
            CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
            
            CGFloat ascent, descent,leading;
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            
            CGPoint baselineOrigin = origins[i];
            baselineOrigin.y = [UIScreen mainScreen].bounds.size.height - baselineOrigin.y-80-ascent;
            
            //行的位置
            CGRect frame = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
            frame.origin = baselineOrigin;
            
            CGPoint point = touchPoint;
            point.x -= baselineOrigin.x;
            
            if (CGRectContainsPoint(frame, touchPoint)){
                CGPoint point = touchPoint;
                point.x -= frame.origin.x+ascent-descent+leading;
                index = CTLineGetStringIndexForPosition(line, point);
                break;
            }
        }
        
    }
    free(origins);
    return index;
}

+ (NSInteger)paragraphFromIndex:(CFIndex)index epubPage:(EpubPage *)epubPage{
    NSString *text = epubPage.epubContent.content;
    text = [text substringToIndex:index];
    NSArray *paraArray = [text componentsSeparatedByString:@"\n"];
    return paraArray.count;
}

+ (NSInteger)paragraphFromIndex:(CFIndex)index epubChapter:(EpubChapter *)epubChapter{
    NSString *text = epubChapter.epubContent.content;
    text = [text substringToIndex:index];
    NSArray *paraArray = [text componentsSeparatedByString:@"\n"];
    return paraArray.count;
}

//获取段落的最后一个字符的index
+ (NSInteger)indexAtTheEndOfParagraphOfText:(NSString *)text queryIndex:(NSInteger)index{
    if (index>text.length-1) {
        return index;
    }
    NSString *subString = [text substringFromIndex:index];
    NSArray *paraArray = [subString componentsSeparatedByString:@"\n"];
    return [paraArray.firstObject length]+index;
}

+ (CGPoint)addLineFrameWithLine:(CTLineRef)line origin:(CGPoint)origin index:(CFIndex)index{
    CGPoint point = ct_lineGetOrigin(line, origin, index);
    point.x += 16;
    point.y += 39;
    point.y = [UIScreen mainScreen].bounds.size.height-point.y;
    return point;
}


+ (NSArray<EpubBadgeModel *> *)badgesWithMarkModels:(NSArray *)markModels epubPage:(EpubPage *)epubPage epubBookModel:(id)bookModel{
    NSMutableArray *badgeArray = [NSMutableArray array];
    for (EpubMarkModel *markModel in markModels) {
        if (markModel.indexEnd<epubPage.range.location||markModel.indexStart>=epubPage.range.location+epubPage.range.length) {
            continue;
        }
        if (!markModel.markInfo.length) {
            continue;
        }
        
        NSInteger index = markModel.indexEnd;
        if (index>epubPage.range.location+epubPage.range.length-1) {
            index = epubPage.range.location+epubPage.range.length-1;
        }
        NSInteger paragraph = [self paragraphFromIndex:index epubPage:epubPage];
        
        if ([markModel.userId isEqualToString:GetUserInfo(USER_ID)]) {
            CGPoint point = ct_frameGetOriginAtIndex(index+1, epubPage.frameRef);
            EpubBadgeModel *badgeModel = [[EpubBadgeModel alloc]init];
            badgeModel.mindModels = @[markModel];
            badgeModel.epubPage = epubPage;
            badgeModel.center = point;
            badgeModel.paragraph = paragraph;
            badgeModel.num = 1;
            badgeModel.isContainedMyMind = YES;
            [badgeArray addObject:badgeModel];
        }else{
            BOOL flag = NO;//是否之前已经生成过相同段落的EpubBadgeModel
            for (EpubBadgeModel *model in badgeArray) {
                if (model.paragraph == paragraph) {
                    //                CGPoint point = [self originAtIndex:index+1 frameRef:epubPage.frameRef];
                    //                model.center = point;
                    if (!model.isContainedMyMind) {
                        if (![markModel.userId isEqualToString:GetUserInfo(USER_ID)]&&!markModel.userId) {
                            //                        index = [self indexAtTheEndOfParagraphOfText:text queryIndex:index];//将button放在末尾
                        }
                        CGPoint point = ct_frameGetOriginAtIndex(index+1, epubPage.frameRef);
                        model.center = point;
                    }
                    
                    model.isContainedMyMind = YES;
                    NSMutableArray *mindModels = [NSMutableArray arrayWithArray:model.mindModels];
                    [mindModels addObject:markModel];
                    model.mindModels = mindModels;
                    ++model.num;
                    flag = YES;
                    break;
                }
            }
            if (flag) {
                continue;
            }
            CGPoint point = ct_frameGetOriginAtIndex(index+1, epubPage.frameRef);
            EpubBadgeModel *badgeModel = [[EpubBadgeModel alloc]init];
            badgeModel.mindModels = @[markModel];
            badgeModel.epubPage = epubPage;
            badgeModel.center = point;
            badgeModel.paragraph = paragraph;
            badgeModel.num = 1;
            badgeModel.isContainedMyMind = NO;
            [badgeArray addObject:badgeModel];
        }
        
//        BOOL flag = NO;//是否之前已经生成过相同段落的EpubBadgeModel
//        for (EpubBadgeModel *model in badgeArray) {
//            if (model.paragraph == paragraph) {
////                CGPoint point = [self originAtIndex:index+1 frameRef:epubPage.frameRef];
////                model.center = point;
//                if (!model.isContainedMyMind) {
//                    if (![markModel.userId isEqualToString:GetUserInfo(USER_ID)]&&!markModel.userId) {
////                        index = [self indexAtTheEndOfParagraphOfText:text queryIndex:index];//将button放在末尾
//                    }
//                    CGPoint point = [self originAtIndex:index+1 frameRef:epubPage.frameRef];
//                    model.center = point;
//                }
//                
//                model.isContainedMyMind = YES;
//                NSMutableArray *mindModels = [NSMutableArray arrayWithArray:model.mindModels];
//                [mindModels addObject:markModel];
//                model.mindModels = mindModels;
//                ++model.num;
//                flag = YES;
//                break;
//            }
//        }
//        if (flag) {
//            continue;
//        }
//        BOOL isContainedMyMind = NO;
////        if ([markModel.userId isEqualToString:GetUserInfo(USER_ID)]) {
////            isContainedMyMind = YES;
////        }else{
////            isContainedMyMind = YES;
////        }
//        CGPoint point = [self originAtIndex:index+1 frameRef:epubPage.frameRef];
//        EpubBadgeModel *badgeModel = [[EpubBadgeModel alloc]init];
//        badgeModel.mindModels = @[markModel];
//        badgeModel.epubPage = epubPage;
//        badgeModel.center = point;
//        badgeModel.paragraph = paragraph;
//        badgeModel.num = 1;
//        badgeModel.isContainedMyMind = isContainedMyMind;
//        [badgeArray addObject:badgeModel];
    }
    
    return [badgeArray copy];
}

+ (void)getBadgesWithMarkModels:(NSArray *)markModels
                       epubPage:(EpubPage *)epubPage
                  epubBookModel:(id)bookModel
                     completion:(void (^)(NSArray *))completion{
    dispatch_async(business_concurrent_queue(), ^{
        NSArray *badges = [self badgesWithMarkModels:markModels epubPage:epubPage epubBookModel:bookModel];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(badges);
            });
        }
    });
}

@end
