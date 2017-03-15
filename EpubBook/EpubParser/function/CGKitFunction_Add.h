
#ifndef CGKitFunction_Add_h
#define CGKitFunction_Add_h

@import Foundation;
@import CoreGraphics;
@import CoreFoundation;

#define NSRangeZero NSMakeRange(0, 0)

typedef NS_ENUM(NSUInteger, NSRangeCompareType) {
    NSRangeCompareTypeEqual = 1,
    NSRangeCompareTypeContains,
    NSRangeCompareTypeBeContained,
    NSRangeCompareTypeGreater,
    NSRangeCompareTypeLess,
    NSRangeCompareTypeInsectionLeft,
    NSRangeCompareTypeInsectionRight
};
NSRange NSMakeRangeWithInterval(NSInteger startIndex,NSInteger endIndex);
CFRange NSRangeTransferToCFRange(NSRange range);
NSInteger NSRangeGetEndLocation(NSRange range);
BOOL NSRangeEqualToRange(NSRange range1, NSRange range2);
BOOL NSRangeContainsRange(NSRange range1, NSRange range2);
BOOL NSRangeContainsLocation(NSRange range, NSInteger location);
BOOL NSRangeGreaterThanRange(NSRange range1, NSRange range2);
NSRange NSRangeInsection(NSRange range1, NSRange range2);
NSRangeCompareType NSRangeCompare(NSRange range1, NSRange range2);


#endif /* CGKitFunction_Add_h */
