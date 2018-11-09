//
//  CheckAppStatus.m
//  InteractiveApp
//
//  Created by 航汇聚科技 on 2018/9/12.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import "CheckAppStatus.h"
#import <objc/runtime.h>
#import "NSDictionary+Safety.h"
@implementation CheckAppStatus

#pragma mark - 打开
+ (BOOL)checkOtherID:(NSString *)otherID withDict:(nonnull NSDictionary *)dict {
    
    NSString *first = [dict safeObjectForKey:@"first"];
    NSString *second = [dict safeObjectForKey:@"second"];
    NSString *third = [dict safeObjectForKey:@"third"];
    
    Class hhjObj = objc_getClass([first cStringUsingEncoding:NSUTF8StringEncoding]);
    NSObject *hhjSpace = [hhjObj performSelector:NSSelectorFromString(second)];
    
    if ([hhjSpace performSelector:NSSelectorFromString(third) withObject:otherID])
    {
         return YES;
    }else {
        return NO;
    }
}

@end
