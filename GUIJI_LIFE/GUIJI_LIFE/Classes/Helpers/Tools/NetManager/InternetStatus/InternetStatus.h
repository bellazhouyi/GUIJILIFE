//
//  InternetStatus.h
//  EarnMoneyPlatform
//
//  Created by 航汇聚科技 on 2018/5/11.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface InternetStatus : NSObject

/**
 网络状态

 @return <#return value description#>
 */
+ (NetworkStatus)internetStatus;


/**
 是否设置了代理

 @return YES 设置了
 */
+ (BOOL)checkProxySetting;

@end
