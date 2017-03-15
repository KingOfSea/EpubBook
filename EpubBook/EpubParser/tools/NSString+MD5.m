
#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>
@implementation NSString (MD5)

-(NSString *)MD5_16StringWithCapital:(BOOL)capital
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSMutableString * md5String = [[NSMutableString alloc]init];
    NSString * para = capital?@"%02X":@"%02x";
    for (NSInteger index = 4; index<12; index++) {
        [md5String appendFormat:para,result[index]];
    }
    return md5String;
    
}

-(NSString *)MD5_32StringWithCapital:(BOOL)capital
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSMutableString * md5String = [[NSMutableString alloc]init];
    NSString * para = capital?@"%02X":@"%02x";
    for (NSInteger index = 0; index<16; index++) {
        [md5String appendFormat:para,result[index]];
    }
    return md5String;
}

- (NSString *)MD5_16NumString{
    NSString *md5_string = [self MD5_16StringWithCapital:YES];
    return [self numStringWithString:md5_string];
}

- (NSString *)MD5_32NumString{
    NSString *md5_string = [self MD5_32StringWithCapital:YES];
    return [self numStringWithString:md5_string];
}

- (NSString *)numStringWithString:(NSString *)str{
    NSMutableString *muteString = [NSMutableString stringWithString:str];
    for (NSInteger i = 0; i<muteString.length; i++) {
        NSString *str = [muteString substringWithRange:NSMakeRange(i, 1)];
        
        str = [self stringWithChangeString:str];
        [muteString replaceCharactersInRange:NSMakeRange(i, 1) withString:str];
    }
    return [muteString copy];
}

- (NSString *)stringWithChangeString:(NSString *)str{
    if ([str isEqualToString:@"A"]) {
        return @"1";
    }
    if ([str isEqualToString:@"B"]) {
        return @"2";
    }
    if ([str isEqualToString:@"C"]) {
        return @"3";
    }
    if ([str isEqualToString:@"D"]) {
        return @"4";
    }
    if ([str isEqualToString:@"E"]) {
        return @"5";
    }
    if ([str isEqualToString:@"F"]) {
        return @"6";
    }
    return str;
}

@end
