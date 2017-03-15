
#import "FileManagerUtil.h"

@implementation FileManagerUtil

+(BOOL)cycleCreateWithPath:(NSString *)filePath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    NSArray * array = [filePath componentsSeparatedByString:@"/"];
    NSFileManager * manager = [NSFileManager defaultManager];
    NSMutableString * path = [[NSMutableString alloc]init];
    for (NSInteger count = 0;count<array.count;count++) {
        NSString * subPath = [NSString stringWithFormat:@"/%@",[array objectAtIndex:count]];
        if ([subPath isEqualToString:@"/"]) {
            continue;
        }
        [path appendString:subPath];
        if (![manager fileExistsAtPath:path]) {
            if (count != array.count-1) {
                if (![manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil]) {
                    return NO;
                }
            }
            else
            {
                if (![manager createFileAtPath:path contents:nil attributes:nil]) {
                    return NO;
                }
                
            }
        }
    }
    return YES;
}

+(BOOL)cycleCreateWithDirectoryPath:(NSString *)directoryPath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        return YES;
    }
    NSArray * array = [directoryPath componentsSeparatedByString:@"/"];
    NSFileManager * manager = [NSFileManager defaultManager];
    NSMutableString * path = [[NSMutableString alloc]init];
    for (NSInteger count = 0;count<array.count;count++) {
        NSString * subPath = [NSString stringWithFormat:@"/%@",[array objectAtIndex:count]];
        if ([subPath isEqualToString:@"/"]) {
            continue;
        }
        [path appendString:subPath];
        NSError *error;
        if (![manager fileExistsAtPath:path]) {
            if (![manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
                return NO;
            }
        }
    }
    return YES;
}

@end
