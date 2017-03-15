
#import "CGKitFunction_Add.h"

NSRange NSMakeRangeWithInterval(NSInteger startIndex,NSInteger endIndex){
    return NSMakeRange(startIndex, endIndex-startIndex+1);
}

CFRange NSRangeTransferToCFRange(NSRange range){
    return CFRangeMake(range.location, range.length);
}

NSInteger NSRangeGetEndLocation(NSRange range){
    return range.location+range.length-1;
}

BOOL NSRangeEqualToRange(NSRange range1, NSRange range2){
    return range1.location == range2.location&&range1.length==range2.length;
}

BOOL NSRangeContainsRange(NSRange range1, NSRange range2){
    BOOL condition1 = range1.location<=range2.location;
    BOOL condition2 = NSRangeGetEndLocation(range1)>=NSRangeGetEndLocation(range2);
    return condition1&&condition2;
}

BOOL NSRangeContainsLocation(NSRange range, NSInteger location){
    if (location<0) {
        return NO;
    }
    return location>=range.location&&location<=NSRangeGetEndLocation(range);
}

BOOL NSRangeGreaterThanRange(NSRange range1, NSRange range2){
    return range1.location>NSRangeGetEndLocation(range2);
}

NSRange NSRangeInsection(NSRange range1, NSRange range2){
    if (NSRangeGreaterThanRange(range1,range2)||NSRangeGreaterThanRange(range2,range1)) {
        return NSRangeZero;
    }
    NSInteger beginLocation = MAX(range1.location, range2.location);
    NSInteger endLocation = MIN(NSRangeGetEndLocation(range1), NSRangeGetEndLocation(range2));
    
    return NSMakeRangeWithInterval(beginLocation, endLocation);
}

NSRangeCompareType NSRangeCompare(NSRange range1, NSRange range2){
    if (NSRangeEqualToRange(range1,range2)) {
        return NSRangeCompareTypeEqual;
    }
    if (NSRangeContainsRange(range1,range2)) {
        return NSRangeCompareTypeContains;
    }
    if (NSRangeContainsRange(range2,range1)) {
        return NSRangeCompareTypeBeContained;
    }
    if (NSRangeGreaterThanRange(range1, range2)) {
        return NSRangeCompareTypeGreater;
    }
    if (NSRangeGreaterThanRange(range2, range1)) {
        return NSRangeCompareTypeLess;
    }
    if (range1.location>range2.location) {
        return NSRangeCompareTypeInsectionLeft;
    }
    return NSRangeCompareTypeInsectionRight;
}
