//
//  ClockHelper.h
//  闹钟测试
//
//  Created by lanou3g on 15/11/13.
//  Copyright © 2015年 胡保轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;

@interface ClockHelper : NSObject


//所有通知
@property(nonatomic,strong) NSArray *notificationArray;


#pragma mark 单例方法
+(instancetype)sharedClockHelper;


#pragma mark 添加本地通知
-(UILocalNotification *)addLocalNotificationWithTime:(NSString *)time
                            content:(NSString *)content;


#pragma mark 生成当天的某个具体时间点
- (NSDate *)getCustomDateWithHour:(NSInteger)hour;

#pragma mark 根据time移除本地通知
-(void)removeNotificationWithTime:(NSString *)time;

@end
