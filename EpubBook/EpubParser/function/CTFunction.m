
#import "CTFunction.h"
@import UIKit;

NSArray* ct_frameGetFrameOfStringInRange(CTFrameRef frameRef, CFRange range){
    CFRange frameRefRange = CTFrameGetStringRange(frameRef);
    range = CFRangeInsection(frameRefRange, range);
    if (CFRangeEqualToRange(range, CFRangeZero)) {
        return nil;
    }
    NSArray *lines = (NSArray*)CTFrameGetLines(frameRef);
    NSInteger lineCount = [lines count];
    //获取整个CTFrame的大小
    CGPathRef path = CTFrameGetPath(frameRef);
    CGRect frameRefRect = CGPathGetBoundingBox(path);
    //获取所有行的起点
    CGPoint *origins = (CGPoint*)malloc(lineCount * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    NSMutableArray *rects = [NSMutableArray array];
    for (CFIndex index = 0; index<lines.count; index++) {
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:index];
        CFRange rangeOfLine = CTLineGetStringRange(line);
        CFRange rangeOfInsection = CFRangeInsection(rangeOfLine, range);
        if (!CFRangeEqualToRange(rangeOfInsection, CFRangeZero)) {
            CGRect frame = ct_lineGetFrame(line, origins[index], rangeOfInsection);
            frame = CGRectOffset(frame, frameRefRect.origin.x, frameRefRect.origin.y);
            
            [rects addObject:[NSValue valueWithCGRect:frame]];
        }
    }
    free(origins);
    return [rects copy];
}

CGRect ct_lineGetFrame(CTLineRef line, CGPoint origin, CFRange range){
    //    if (!CFRangeContainsRange(CTLineGetStringRange(line), range)) {
    //        @throw [NSException exceptionWithName:@"excute ct_lineGetFrame error!" reason:@"CFRange is not contain appoint CFRange.(CFRange不包含指定的CFRange)" userInfo:nil];
    //        return CGRectZero;
    //    }
    CFRange lineRange = CTLineGetStringRange(line);
    range = CFRangeInsection(lineRange, range);
    CGFloat trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(line);
    if (CFRangeGetEndLocation(range)==CFRangeGetEndLocation(lineRange)&&trailingWhitespaceWidth>0) {
        --range.length;
    }
    CGFloat xStart = CTLineGetOffsetForStringIndex(line, range.location, NULL);//获取整段文字中charIndex位置的字符相对line的原点的x值
    CGFloat xEnd = CTLineGetOffsetForStringIndex(line, CFRangeGetEndLocation(range)+1, NULL);
    
    CGFloat ascent, descent, leading;
    
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGRect selectionRect = CGRectMake(origin.x + xStart,
                                      origin.y - descent,
                                      xEnd - xStart,
                                      ascent + descent + leading);
    
    return selectionRect;
}

CGPoint ct_lineGetOrigin(CTLineRef line, CGPoint origin, CFIndex index){
    //    if (!CFRangeContainsRange(CTLineGetStringRange(line), index)) {
    //        @throw [NSException exceptionWithName:@"excute ct_lineGetOrigin error!" reason:@"CFRange is not contain appoint index.(CFRange不包含指定的index)" userInfo:nil];
    //        return CGPointZero;
    //    }
    CGFloat xStart = CTLineGetOffsetForStringIndex(line, index, NULL);//获取整段文字中charIndex位置的字符相对line的原点的x值
    
    CGFloat ascent, descent;
    CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
    
    CGPoint point = CGPointMake(origin.x + xStart, origin.y - descent);
    
    //point.x += 16;
    //point.y += 39;
    //point.y = [UIScreen mainScreen].bounds.size.height-point.y;
    return point;
}


CGPoint ct_frameGetOriginAtIndex(CFIndex index, CTFrameRef frameRef){
    
    NSArray *lines = (NSArray*)CTFrameGetLines(frameRef);
    CGPoint *origins = (CGPoint*)malloc([lines count] * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0,0), origins);
    
    for (NSInteger i = 0;i<lines.count;i++) {
        id lineObj = lines[i];
        CTLineRef line = (__bridge CTLineRef)(lineObj);
        CFRange range = CTLineGetStringRange(line);
        if (CFRangeContainsLocation(range, index)) {
            //            return [self addLineFrameWithLine:line origin:origins[i] index:index];
            return ct_lineGetOrigin(line, origins[i], index);
        }
    }
    return CGPointZero;
}

CFIndex ct_frameGetStringIndexForPosition(CTFrameRef frameRef, CGPoint touchPoint, BOOL allowWhiteSpace){
    
    NSArray *lines = (NSArray*)CTFrameGetLines(frameRef);
    NSInteger lineCount = [lines count];
    if (!lineCount) {
        return kCFNotFound;
    }
    //获取整个CTFrame的大小
    CGPathRef path = CTFrameGetPath(frameRef);
    CGRect frameRefRect = CGPathGetBoundingBox(path);
    if (!CGRectContainsPoint(frameRefRect, touchPoint)&&!allowWhiteSpace) {
        return kCFNotFound;
    }
    //获取所有行的起点
    CGPoint *origins = (CGPoint*)malloc(lineCount * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    //待计算结果
    CFIndex index = kCFNotFound;
    CTLineRef curLine = NULL;
    CGFloat offset = 0;
    BOOL hasContainedEnterChar = NO;
    //遍历所有行
    for (int i = 0; i < lineCount; i++){
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
        CGFloat ascent, descent,leading;
        CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(line);
        //转换行的起始位置
        CGPoint lineOrigin = origins[i];
        lineOrigin.x += frameRefRect.origin.x;
        lineOrigin.y = frameRefRect.origin.y+frameRefRect.size.height - lineOrigin.y;
        //如果行的纵坐标大于点击手势的纵坐标
        if (lineOrigin.y>touchPoint.y) {
            if (!allowWhiteSpace&&lineOrigin.x+width<touchPoint.x) {
                break;
            }
            curLine = line;
            offset = lineOrigin.x+(ascent+descent+leading)/2;//不知道为什么，CTLineGetStringIndexForPosition函数计算的并不准确，有半个首字符的偏移量
            hasContainedEnterChar = trailingWhitespaceWidth>0;
            break;
        }
    }
    touchPoint.x -= offset;
    index = CTLineGetStringIndexForPosition(curLine, touchPoint);
    CFRange lineRange = CTLineGetStringRange(curLine);
    if (index != kCFNotFound) {
        if (!CFRangeContainsLocation(lineRange, index)) {//得到index的不在该行,在下一行的起始位置
            index = CFRangeGetEndLocation(lineRange);
            if (hasContainedEnterChar) {
                --index;
            }
        }
    }
    free(origins);
    return index;
};

CGRect ct_frameGetLineFrame(CTFrameRef frameRef, CFIndex lineNum){
    NSArray *lines = (NSArray*)CTFrameGetLines(frameRef);
    if (!lines||lines.count<=lineNum) {
        return CGRectZero;
    }
    CGPathRef path = CTFrameGetPath(frameRef);
    //获取整个CTFrame的大小
    CGRect frameRefRect = CGPathGetBoundingBox(path);
//    return frameRefRect;
    
    NSInteger lineCount = [lines count];
    
    CGPoint *origins = (CGPoint*)malloc(lineCount * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:lineNum];
    
    CGFloat ascent, descent,leading;
    CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)-CTLineGetTrailingWhitespaceWidth(line);
    CGPoint baselineOrigin = origins[lineNum];
    baselineOrigin.y = baselineOrigin.y-descent;
    CGRect frame = CGRectZero;
    frame.origin = baselineOrigin;
    frame.size.width = width;
    frame.size.height = ascent+descent+leading;
    frame = CGRectOffset(frame, frameRefRect.origin.x, frameRefRect.origin.y);

    free(origins);
    
    return frame;
}

NSArray* ct_frameGetAllLinesTypographicBounds(CTFrameRef frameRef){
    NSArray *lines = (NSArray*)CTFrameGetLines(frameRef);
    if (!lines.count) {
        return nil;
    }
    
    CGPathRef path = CTFrameGetPath(frameRef);
    //获取整个CTFrame的大小
    CGRect frameRefRect = CGPathGetBoundingBox(path);
    
    CGPoint *origins = (CGPoint*)malloc(lines.count * sizeof(CGPoint));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (CFIndex index = 0; index<lines.count; index++) {
        CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:index];
        
        CGFloat ascent, descent,leading;
        CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)-CTLineGetTrailingWhitespaceWidth(line);
        CGPoint baselineOrigin = origins[index];
        baselineOrigin.y = baselineOrigin.y-descent;
        CGRect frame = CGRectZero;
        frame.origin = baselineOrigin;
        frame.size.width = width;
        frame.size.height = ascent+descent+leading;
        frame = CGRectOffset(frame, frameRefRect.origin.x, frameRefRect.origin.y);
        [mutableArray addObject:[NSValue valueWithCGRect:frame]];
    }
    free(origins);
    return [mutableArray copy];
}

