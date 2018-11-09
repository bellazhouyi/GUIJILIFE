//
//  InternetStatus.m
//  EarnMoneyPlatform
//
//  Created by 航汇聚科技 on 2018/5/11.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import "InternetStatus.h"


@implementation InternetStatus

+ (NetworkStatus)internetStatus {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    NetworkStatus netStatus;
    switch (internetStatus) {
        case ReachableViaWiFi:
            netStatus = ReachableViaWiFi;
            break;
            
        case ReachableViaWWAN:
            netStatus = ReachableViaWWAN;
            //net = [self getNetType ];   //判断具体类型
            break;
            
        case NotReachable:
            netStatus = NotReachable;
            
        default:
            break;
    }
    
    return netStatus;
}

+ (BOOL)checkProxySetting {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.sjinke.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    
     NSDictionary *settings = proxies[0];
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
        return NO;
    }else {
        //设置了代理
        return YES;
    }
}

@end
