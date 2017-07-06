//
//  NSString+Encrypt.m
//  汇聚书屋
//
//  Created by 航汇聚科技 on 2017/6/13.
//  Copyright © 2017年 航汇聚科技. All rights reserved.
//



#import "NSString+Encrypt.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Encrypt)

//FIXME: MD5加密
+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digets[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digets);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",digets[i]];
    }
    
    return output;
}

//FIXME: 异或加解密
void xorString(unsigned char *str, unsigned char key) {
    unsigned char *p = str;
    while( ((*p) ^=  key) != '\0')  p++;
}

+ (NSString *)tokenNew_key:(unsigned char *)str {
    xorString(str, XOR_KEY);
    static unsigned char result[100];
    memcpy(result, str, 100);
    return [NSString stringWithFormat:@"%s",result];
}

@end
