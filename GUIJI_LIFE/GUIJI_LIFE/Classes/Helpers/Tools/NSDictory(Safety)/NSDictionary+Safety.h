//
//  NSDictionary+Safety.h
//  FNMenu
//
//  Created by 航汇聚科技 on 2018/9/12.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Safety)

- (id)safeObjectForKey:(NSString*)key;

- (void)setSafeValue:(id)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
