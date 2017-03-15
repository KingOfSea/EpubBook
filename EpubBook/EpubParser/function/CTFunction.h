
#ifndef CTFunction_h
#define CTFunction_h

@import Foundation;
@import CoreGraphics;
@import CoreFoundation;
@import CoreText;

#import "CGKitFunction_Add.h"
#import "CFKitFunction_Add.h"

CGRect ct_lineGetFrame(CTLineRef line, CGPoint origin, CFRange range);
CGPoint ct_lineGetOrigin(CTLineRef line, CGPoint origin, CFIndex index);
CGPoint ct_frameGetOriginAtIndex(CFIndex index, CTFrameRef frameRef);
CFIndex ct_frameGetStringIndexForPosition(CTFrameRef frameRef, CGPoint touchPoint, BOOL allowWhiteSpace);
CGRect ct_frameGetLineFrame(CTFrameRef frameRef, CFIndex lineNum);
NSArray* ct_frameGetAllLinesTypographicBounds(CTFrameRef frameRef);
NSArray* ct_frameGetFrameOfStringInRange(CTFrameRef frameRef, CFRange range);


#endif /* CTFunction_h */
