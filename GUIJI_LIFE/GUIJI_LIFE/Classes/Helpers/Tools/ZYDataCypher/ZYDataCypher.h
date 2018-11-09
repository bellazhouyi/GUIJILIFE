//
//  ZYDataCypher.h
//  EachDayReader
//
//  Created by 航汇聚科技 on 2017/11/3.
//  Copyright © 2017年 Yi Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYDataCypher : NSObject

+ (instancetype)sharedDataCypher;
/**
 * 加密并写入数据
 */
- (NSString *)writeData:(NSString *)writeData;
/**
 * 读取数据并解密
 */
- (NSString *)readData:(NSString *)reciveData;

/**
 json字符串转化成OC键值对

 @param JSONString <#JSONString description#>
 @return <#return value description#>
 */
- (id)jsonStringToKeyValues:(NSString *)JSONString;
@end
