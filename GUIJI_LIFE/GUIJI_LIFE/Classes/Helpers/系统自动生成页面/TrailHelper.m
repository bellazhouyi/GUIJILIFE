//
//  TrailHelper.m
//  GUIJI_LIFE
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "TrailHelper.h"

@interface TrailHelper ()

//声明AppDelegate实例
@property(nonatomic,strong) AppDelegate *appDelegate;


@end


@implementation TrailHelper


#pragma mark 单例方法
+(instancetype)sharedTrailHelper{
    static TrailHelper *trailHepler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trailHepler = [TrailHelper new];
    });
    return trailHepler;
}


#pragma mark 存数据
-(void)saveMapInfoWithTime:(NSString *)time date:(NSString *)date andLocationName:(NSString *)locationName{
    
    //获得实体描述实例
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MapInfo" inManagedObjectContext:self.appDelegate.managedObjectContext];
    
    //根据实体描述实例获得实体
    MapInfo *mapInfo = [[MapInfo alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:self.appDelegate.managedObjectContext];
    
    //给数据库实体的各个字段赋值
    mapInfo.time = time;
    mapInfo.date = date;
    mapInfo.locationName = locationName;
    
    //保存并更新
    [self.appDelegate saveContext];
    
}

#pragma mark 根据日期筛选数据
-(NSArray *)filterMapInfoDataByDate:(NSString *)date{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MapInfo" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date = %@", date];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"当前日期下没有相应的数据");
    }
    
    return fetchedObjects;
}


#pragma mark 返回数据库中的所有信息
-(NSArray *)gainAllMapInfoFromCoreData{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MapInfo" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    
    return fetchedObjects;
}



#pragma mark 返回所有数据
-(NSArray *)allMapInfo{
    return  [self gainAllMapInfoFromCoreData];
}


#pragma mark 移除多个相同时间的数据
-(NSArray *)removeDataWithSimpleDataByDate:(NSString *)date{
    NSArray *mapInfoArray = [self filterMapInfoDataByDate:date];
    
    NSMutableArray *arrayMapInfo = [NSMutableArray arrayWithArray:mapInfoArray];
    
    //去掉数据中时间重复的数据
    for (int count = 0; count < arrayMapInfo.count; count ++) {
        if ([arrayMapInfo[count] locationName] == NULL) {
            //从数据中删除
            [self.appDelegate.managedObjectContext deleteObject:arrayMapInfo[count]];
            [self.appDelegate saveContext];
            //之前在这里数组越界，是因为自己之前的代码，如果是最后一个元素，先在数组中移除了next,后来又要取next,但是next已经被删除了，是找不到对应的，所以报错。
            [arrayMapInfo removeObjectAtIndex:count];
        }else{
        for (int next = count+1; next < arrayMapInfo.count ; ) {
            if ([[arrayMapInfo[count] time] isEqualToString:[arrayMapInfo[next] time]]) {
                
                //从数据中删除
                [self.appDelegate.managedObjectContext deleteObject:arrayMapInfo[next]];
                [self.appDelegate saveContext];
                
                [arrayMapInfo removeObjectAtIndex:next];
                
            }else{
                next ++;
            }
        }
    }
    
    //移除同一个时间段内,
    for (int count = 0; count < arrayMapInfo.count; count ++) {
        //数组中第count个元素的小时
        NSString *countHour = [[arrayMapInfo[count] time] substringToIndex:2];
        for (int next = count + 1; next < arrayMapInfo.count; ) {
            //数组中第next个元素的小时
            NSString *nextHour = [[arrayMapInfo[next] time] substringToIndex:2];
            //如果两个元素所处的小时段是一致的并且地理位置也一直没有改变,则剔除舍弃。
            if ([countHour isEqualToString:nextHour] && [[arrayMapInfo[count] locationName] isEqualToString:[arrayMapInfo[next] locationName]]) {
                //从数据库中删除
                [self.appDelegate.managedObjectContext deleteObject:arrayMapInfo[next]];
                [self.appDelegate saveContext];
                
                //从数组中移除
                [arrayMapInfo removeObjectAtIndex:next];
                
            }else{
                next ++;
            }
        }
    }
    }
    return arrayMapInfo;
    
}


#pragma mark appDelegate懒加载
-(AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = [UIApplication sharedApplication].delegate;
    }
    return _appDelegate;
}

@end
