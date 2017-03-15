
#import "CFKitFunction_Add.h"

CFRange CFRangeMakeWithInterval(CFIndex startIndex,CFIndex endIndex){
    return CFRangeMake(startIndex, endIndex-startIndex+1);
}

NSRange CFRangeTransferToNSRange(CFRange range){
    return NSMakeRange(range.location, range.length);
}

CFIndex CFRangeGetEndLocation(CFRange range){
    return range.location+range.length-1;
}

BOOL CFRangeEqualToRange(CFRange range1, CFRange range2){
    return range1.location == range2.location&&range1.length==range2.length;
}

BOOL CFRangeContainsRange(CFRange range1, CFRange range2){
    BOOL condition1 = range1.location<=range2.location;
    BOOL condition2 = CFRangeGetEndLocation(range1)>=CFRangeGetEndLocation(range2);
    return condition1&&condition2;
}

BOOL CFRangeContainsLocation(CFRange range, CFIndex location){
    if (location<0) {
        return NO;
    }
    return location>=range.location&&location<=CFRangeGetEndLocation(range);
}

BOOL CFRangeGreaterThanRange(CFRange range1, CFRange range2){
    return range1.location>CFRangeGetEndLocation(range2);
}

CFRange CFRangeInsection(CFRange range1, CFRange range2){
    if (CFRangeGreaterThanRange(range1,range2)||CFRangeGreaterThanRange(range2,range1)) {
        return CFRangeZero;
    }
    CFIndex beginLocation = MAX(range1.location, range2.location);
    CFIndex endLocation = MIN(CFRangeGetEndLocation(range1), CFRangeGetEndLocation(range2));
    
    return CFRangeMakeWithInterval(beginLocation, endLocation);
}

CFRangeCompareType CFRangeCompare(CFRange range1, CFRange range2){
    if (CFRangeEqualToRange(range1,range2)) {
        return CFRangeCompareTypeEqual;
    }
    if (CFRangeContainsRange(range1,range2)) {
        return CFRangeCompareTypeContains;
    }
    if (CFRangeContainsRange(range2,range1)) {
        return CFRangeCompareTypeBeContained;
    }
    if (CFRangeGreaterThanRange(range1, range2)) {
        return CFRangeCompareTypeGreater;
    }
    if (CFRangeGreaterThanRange(range2, range1)) {
        return CFRangeCompareTypeLess;
    }
    if (range1.location>range2.location) {
        return CFRangeCompareTypeInsectionLeft;
    }
    return CFRangeCompareTypeInsectionRight;
}
