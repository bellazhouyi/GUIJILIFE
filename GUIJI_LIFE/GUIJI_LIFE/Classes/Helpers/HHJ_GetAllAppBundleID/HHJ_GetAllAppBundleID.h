//
//  HHJ_GetAllAppBundleID.h
//  汇聚书屋
//
//  Created by 航汇聚科技 on 2017/6/16.
//  Copyright © 2017年 航汇聚科技. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * 获取手机里所有的APP 包名
 */
@interface HHJ_GetAllAppBundleID : NSObject


@property(nonatomic, strong, readonly) NSArray *allInstalledBundleID;

- (void)touss;

/*
 * 打开某一个应用
 */
- (void)openApplicationWithBundleID:(NSString *)bundleID;


@end
