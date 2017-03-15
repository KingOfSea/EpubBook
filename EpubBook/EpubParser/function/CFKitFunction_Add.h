

#ifndef CFKitFunction_Add_h
#define CFKitFunction_Add_h

@import Foundation;
@import CoreGraphics;
@import CoreFoundation;

#define CFRangeZero CFRangeMake(0, 0)

typedef NS_ENUM(NSUInteger, CFRangeCompareType) {
    CFRangeCompareTypeEqual = 1,
    CFRangeCompareTypeContains,
    CFRangeCompareTypeBeContained,
    CFRangeCompareTypeGreater,
    CFRangeCompareTypeLess,
    CFRangeCompareTypeInsectionLeft,
    CFRangeCompareTypeInsectionRight
};

CFRange CFRangeMakeWithInterval(CFIndex startIndex,CFIndex endIndex);
NSRange CFRangeTransferToNSRange(CFRange range);
CFIndex CFRangeGetEndLocation(CFRange range);
BOOL CFRangeEqualToRange(CFRange range1, CFRange range2);
BOOL CFRangeContainsRange(CFRange range1, CFRange range2);
BOOL CFRangeContainsLocation(CFRange range, CFIndex location);
BOOL CFRangeGreaterThanRange(CFRange range1, CFRange range2);
CFRange CFRangeInsection(CFRange range1, CFRange range2);
CFRangeCompareType CFRangeCompare(CFRange range1, CFRange range2);

#endif /* aa_h */
