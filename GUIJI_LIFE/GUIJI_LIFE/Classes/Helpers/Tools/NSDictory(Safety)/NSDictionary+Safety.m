//
//  NSDictionary+Safety.m
//  FNMenu
//
//  Created by 航汇聚科技 on 2018/9/12.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import "NSDictionary+Safety.h"

@implementation NSDictionary (Safety)
- (id)safeObjectForKey:(NSString*)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSNull class]]) {
        object = nil;
    }
    return object;
}

- (void)setSafeValue:(id)value forKey:(NSString *)key {
    if (value) {
        [self setValue:value forKey:key];
    }
}

@end
