//
//  ZYDataCypher.m
//  EachDayReader
//
//  Created by 航汇聚科技 on 2017/11/3.
//  Copyright © 2017年 Yi Zhou. All rights reserved.
//

#import "ZYDataCypher.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString *EMPTY_MATCH_VALUE = @"P";

@interface ZYDataCypher ()

// 临时值
@property (nonatomic, strong) NSDictionary *tempEncryptData;

@end

@implementation ZYDataCypher

+ (instancetype)sharedDataCypher {
    static ZYDataCypher *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ZYDataCypher new];
    });
    return instance;
}

//MARK:读取文件内容，暂时不用
- (NSDictionary *)readDataFromTxtFile:(NSString *)fileName {
    NSMutableDictionary *result;

    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    result = [self jsonStringToKeyValues:content];
    self.tempEncryptData = result;
    
    return result;
}

- (NSString *)writeData:(NSString *)writeData {
    
    //1.转base64
    NSString *base64Str = [self base64StringFromText:writeData];
    
    //2.对称加密
    NSMutableString *string = [NSMutableString string];
    for (int index = 0; index < [base64Str length]; index++) {
        NSString *temp = [base64Str substringWithRange:NSMakeRange(index, 1)];
        NSString *result = [self valueForKey:temp];
        
        [string appendString:result];
    }
    
    return string;
}

- (NSString *)readData:(NSString *)reciveData {
    //1.对称解密
    NSMutableString *resultStr = [NSMutableString string];
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    // do something
   
    for (int index = 0; index < [reciveData length];) {
        NSString *temp = [reciveData substringWithRange:NSMakeRange(index, 2)];
        NSString *result = [self keyForValue:temp];
        
        [resultStr appendString:result];
        
        index += 2;
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"解密耗时时长：%f", end - start);
    
    //2.base64转码
    return [self textFromBase64String:resultStr];
}

#pragma mark - private

//json字符串转化成OC键值对
- (id)jsonStringToKeyValues:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = nil;
    if (JSONData) {
        responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
        
    }
    return responseJSON;
}
/**
 *  加密
 *
 *  @param key 原始字符
 *
 *  @return 转换后的字符
 */
- (NSString *)valueForKey:(NSString *)key {
    if (!self.tempEncryptData) {
        self.tempEncryptData = [self encryptData];
    }
    
    NSString *result = nil;
    int index = 0;
    for (NSString *itemValue in self.tempEncryptData.allValues) {
        if ([key isEqualToString:itemValue]) {
            result = [self.tempEncryptData allKeys][index];
            if ([result hasPrefix:@"\\"]) {
                result = [result substringWithRange:NSMakeRange(1, 1)];
            }
        }
        index++;
    }
    if (!result) {
        result = [NSString stringWithFormat:@"%@%@", EMPTY_MATCH_VALUE, key];
    }
    return result;
}
/**
 *  解密
 *
 *  @param value 转换后的字符
 *
 *  @return key 原始字符
 */
- (NSString *)keyForValue:(NSString *)value {
    if (!self.tempEncryptData) {
        self.tempEncryptData = [self encryptData];
    }
    
    NSString *result = nil;
    for (NSString *itemKey in self.tempEncryptData.allKeys) {
        NSString *key = itemKey;
        if ([itemKey hasPrefix:@"\\"]) {
            key = [itemKey substringWithRange:NSMakeRange(1, 1)];
        }
        if ([value isEqualToString:key]) {
            result = [self.tempEncryptData valueForKey:itemKey];
        }
    }
    if (!result) {
        //当在字典中查找不到对应的值时，这种情况是错误的。返回**
        result = [value substringWithRange:NSMakeRange(1, 1)];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF == %@",result];
        NSArray *resultArr = [self.tempEncryptData.allKeys filteredArrayUsingPredicate:pre];
        if (resultArr.count != 0) {
            result = @"**";
        }
    }
    
    return result;
}
/**
 *  将普通字符串转换成base64字符串
 *
 *  @param text 普通字符串
 *
 *  @return base64字符串
 */
- (NSString *)base64StringFromText:(NSString *)text {
    
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    
    return base64String;
}
/**
 *  将base64字符串转换成普通字符串
 *
 *  @param base64 base64字符串
 *
 *  @return 普通字符串
 */
- (NSString *)textFromBase64String:(NSString *)base64 {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return text;
}

- (NSDictionary *)encryptData {
    return @{@"BQ":@"&",
             @"BR":@"!",
             @"BY":@"*",
             @"BU":@"'",
             @"BO":@"\"",
             @"BJ":@"(",
             @"BH":@")",
             @"BL":@";",
             @"VA":@":@",
             @"VS":@"@",
             @"VG":@"=",
             @"VJ":@"+",
             @"VL":@"$",
             @"VT":@",@",
             @"VR":@"/",
             @"VE":@"?",
             @"ZA":@"%",
             @"ZB":@"#",
             @"ZC":@"[",
             @"ZD":@"]",
             @"ZF":@"\\",
             @"GC":@"A",
             @"AB":@"B",
             @"AC":@"C",
             @"AD":@"D",
             @"FW":@"E",
             @"AF":@"F",
             @"FB":@"G",
             @"GA":@"H",
             @"BI":@"I",
             @"FR":@"J",
             @"BK":@"K",
             @"FE":@"L",
             @"BM":@"M",
             @"BN":@"N",
             @"FY":@"O",
             @"BV":@"P",
             @"CQ":@"Q",
             @"CR":@"R",
             @"CS":@"S",
             @"CT":@"T",
             @"CU":@"U",
             @"CV":@"V",
             @"CW":@"W",
             @"CX":@"X",
             @"DY":@"Y",
             @"DZ":@"Z",
             @"CC":@"a",
             @"BB":@"b",
             @"EE":@"c",
             @"DD":@"d",
             @"XC":@"e",
             @"FA":@"f",
             @"LO":@"g",
             @"MO":@"h",
             @"JU":@"i",
             @"XR":@"j",
             @"U2":@"k",
             @"U3":@"l",
             @"U4":@"m",
             @"U5":@"n",
             @"U6":@"o",
             @"U7":@"p",
             @"RA":@"q",
             @"RB":@"r",
             @"RX":@"s",
             @"NU":@"t",
             @"AQ":@"u",
             @"QA":@"v",
             @"RG":@"w",
             @"RH":@"x",
             @"WC":@"y",
             @"SE":@"z"};
}

@end
