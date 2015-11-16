//
//  ScheduleHelper.h
//  GUIJI_LIFE
//
//  Created by 邢家赫 on 15/11/12.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface ScheduleHelper : NSObject
// 从数据库中读取数据的数组
@property (nonatomic,strong) NSMutableArray *scheduleArray;

// 设置button上显示时间的数组
@property (nonatomic,strong) NSMutableArray *buttonTitleArray;

@property (nonatomic,strong) AppDelegate *appDelegate;

#pragma mark 存储未来7天的模型
- (void)saveDataWithDate:(NSString *)date hour:(NSNumber *)hour content:(NSString *)content isClock:(BOOL)isColock isShow:(BOOL)isShow showBox:(BOOL)showBox;

#pragma mark 根据日期去数据
- (NSMutableArray *)gainDataWithDate:(NSString *)date;

+ (instancetype)sharedDatamanager;

// 从数据库申请数据
- (void)requestWithDate:(NSString *)date;

@end
