
#import <Foundation/Foundation.h>

@interface FileManagerUtil : NSObject

+(BOOL)cycleCreateWithPath:(NSString *)filePath;
+(BOOL)cycleCreateWithDirectoryPath:(NSString *)directoryPath;

@end
