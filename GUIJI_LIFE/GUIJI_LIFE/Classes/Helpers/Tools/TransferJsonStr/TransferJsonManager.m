//
//  TransferJsonManager.m
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/8.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import "TransferJsonManager.h"

@implementation TransferJsonManager
+ (NSDictionary *)dictFromJsonStr:(NSString *)jsonStr {
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
}
+ (NSString*)jsonStrFromDict:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
@end
