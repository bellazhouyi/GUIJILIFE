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



#pragma mark appDelegate懒加载
-(AppDelegate *)appDelegate{
    if (!_appDelegate) {
        _appDelegate = [UIApplication sharedApplication].delegate;
    }
    return _appDelegate;
}

@end
