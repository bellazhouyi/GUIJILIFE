//
//  JSObjDelegate.h
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/8.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
NS_ASSUME_NONNULL_BEGIN

@protocol JSObjDelegate <JSExport>


- (BOOL)copy:(NSString *)copyStr;
- (NSString *)paste;
- (BOOL)startGravityInduction:(NSString *)taskID;

- (id)openApp:(NSString *)params;

- (id)active:(NSString *)activeInfo;

@end

NS_ASSUME_NONNULL_END
