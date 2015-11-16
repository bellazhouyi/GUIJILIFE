//
//  ScheduleHelper.m
//  GUIJI_LIFE
//
//  Created by 邢家赫 on 15/11/12.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "ScheduleHelper.h"

@interface ScheduleHelper ()


@end


@implementation ScheduleHelper

#pragma mark 单例
+ (instancetype)sharedDatamanager
{
    static ScheduleHelper *scheduleHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scheduleHelper = [ScheduleHelper new];
    });
    return scheduleHelper;
}


- (void)requestWithDate:(NSString *)date
{
    
    // 不能使用懒加载 (否则此方法调用_schedule一直会增加)
    _scheduleArray = [[NSMutableArray alloc] initWithCapacity:10];
        
    // 给scheduleArray初值 直接存进数据库
    _scheduleArray = [self gainDataWithDate:date];
    
    if (_scheduleArray.count == 0)
    {
        
        
            for (int i = 6;  i < 26; i += 2)
            {
                
                
                if (i == 6)
                {
                    
                    // 给第一个气泡添加提醒
                    
                    [self saveDataWithDate:date hour:[NSNumber numberWithInt:i] content:@"这里添加数据" isClock:NO isShow:YES showBox:NO];
                }
                else
                {
                    
                    [self saveDataWithDate:date hour:[NSNumber numberWithInt:i] content:@"" isClock:NO isShow:NO showBox:NO];
                }
                
            }
        
        
        
        // 如果是空 就根据日期获取数据
        _scheduleArray = [self gainDataWithDate:date];
    }
    
    
    
    
}



#pragma mark 存储未来7天模型
- (void)saveDataWithDate:(NSString *)date hour:(NSNumber *)hour content:(NSString *)content isClock:(BOOL)isColock isShow:(BOOL)isShow showBox:(BOOL)showBox
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"NextSchedule" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    NextSchedule *nextSchedule = [[NextSchedule alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.appDelegate.managedObjectContext];
    
    
    nextSchedule.date = date;
    nextSchedule.hour = hour;
    nextSchedule.content = content;
    nextSchedule.isClock = [NSNumber numberWithBool:isColock];
    nextSchedule.isShow = [NSNumber numberWithBool:isShow];
    nextSchedule.showBox = [NSNumber numberWithBool:showBox];
    
    // 保存并更新
    [self.appDelegate saveContext];
    
}

#pragma mark 根据date取数据
- (NSMutableArray *)gainDataWithDate:(NSString *)date
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NextSchedule" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", date];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hour"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"数据为空");
    }
    else
    {
        
        [self.scheduleArray addObjectsFromArray:fetchedObjects];
    }
    
    return _scheduleArray;
    
}








#pragma mark 懒加载
-(AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = [UIApplication sharedApplication].delegate;
    }
    return _appDelegate;
}

@end
