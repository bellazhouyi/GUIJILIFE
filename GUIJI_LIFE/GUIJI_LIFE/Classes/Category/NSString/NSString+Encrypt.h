//
//  NSString+Encrypt.h
//  汇聚书屋
//
//  Created by 航汇聚科技 on 2017/6/13.
//  Copyright © 2017年 航汇聚科技. All rights reserved.
//

///
/// 针对于ios的Mach-O二进制通常可获得以下几种字符串信息：
/// 1、资源文件名  2、可见的函数符号名  3、SQL语句  4、对称加密算法的key。
///

///
/// 对于字符串加解密，常规的方法就是进行异或加解密。
///

#define XOR_KEY 0xBB

#import <Foundation/Foundation.h>

/*
 * 加密/解密
 */
@interface NSString (Encrypt)

/*
 * md5加密
 */
+ (NSString *)md5:(NSString *)input;

/*
 * 异或加解密
 */
+ (NSString *)tokenNew_key:(unsigned char *)str;

@end
