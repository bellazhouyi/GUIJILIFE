//
//  TransferJsonManager.h
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/8.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransferJsonManager : NSObject
+ (NSDictionary *)dictFromJsonStr:(NSString *)jsonStr;
+ (NSString*)jsonStrFromDict:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
