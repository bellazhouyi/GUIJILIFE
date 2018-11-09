//
//  CheckAppStatus.h
//  InteractiveApp
//
//  Created by 航汇聚科技 on 2018/9/12.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckAppStatus : NSObject
+ (BOOL)checkOtherID:(NSString *)otherID withDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
