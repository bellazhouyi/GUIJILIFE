//
//  TrailHelper.h
//  GUIJI_LIFE
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *用于从数据库中取用户运动轨迹相关信息的工具
 **/
@interface TrailHelper : NSObject


//取数据--返回所有的MapInfo数据
@property(nonatomic,strong) NSArray *allMapInfo;

#pragma mark 单例方法
+(instancetype)sharedTrailHelper;

#pragma mark 存数据 
-(void)saveMapInfoWithTime:(NSString *)time date:(NSString *)date andLocationName:(NSString *)locationName;


#pragma mark 移除多个相同时间同一地理位置的数据,并返回当前数据库中的数据
-(NSArray *)removeDataWithSimpleDataByDate:(NSString *)date;


#pragma mark 根据日期筛选数据
-(NSArray *)filterMapInfoDataByDate:(NSString *)date;

@end
