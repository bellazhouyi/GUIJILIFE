//
//  AppDelegate.m
//  GUIJILIFE
//
//  Created by lanou3g on 15/11/9.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "AppDelegate.h"
#import "ClockHelper.h"
#import "TrailHelper.h"
//引入地图框架
@import MapKit;

@interface AppDelegate ()<MKMapViewDelegate,CLLocationManagerDelegate>

//定义CLLocationManager属性
@property(nonatomic,strong) CLLocationManager *locationManager;


@property (nonatomic,strong) Schedule *schedule;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 控制闪屏时间
    [NSThread sleepForTimeInterval:1];
    
    
    //初始化CLLocationManager属性
    self.locationManager = [[CLLocationManager alloc]init];
    
    //判断系统版本
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        
        //设置授权方式
        [self.locationManager requestAlwaysAuthorization];
        
        //用户是否允许位置访问
        [CLLocationManager locationServicesEnabled];
        
    }
    
    //iOS9新特性
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
        //允许后台更新
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    
    self.locationManager.delegate = self;
    
    //开启定位功能
    [self.locationManager startUpdatingLocation];
    
    //设置更新间距
    self.locationManager.distanceFilter = 1;
    
    //设置定位精度
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
#pragma mark - 关于闹钟的
    //如果已经获得发送通知的授权则创建本地通知，否则请求授权(注意：如果不请求授权在设置中是没有对应的通知设置项的，也就是说如果从来没有发送过请求，即使通过设置也打不开消息允许设置)
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
        
        
        //从家赫那个页面---数据库中有isClock这么一个Bool，表示是否有闹钟提醒
        //用通知传值--关于时间的形参，调用addLocalNotificationWithTime方法
        //接收通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startClock:) name:@"clock" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopClock:) name:@"notClock" object:nil];
    }else{
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    

    
    return YES;
}

#pragma mark 处理从MyCell通知中心接收到的通知--开启闹钟
-(void)startClock:(NSNotification *)sender{
    
    NSString *time = sender.userInfo[@"time"];
    NSString *content = sender.userInfo[@"content"];
    
    ClockHelper *clockHelper = [ClockHelper sharedClockHelper];
    
    UILocalNotification *notification = [clockHelper addLocalNotificationWithTime:time content:content];
    
    //调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark 处理从MyCell通知中心接收到的通知--关闭闹钟
-(void)stopClock:(NSNotification *)sender{
    NSString *time = sender.userInfo[@"time"];
    //遍历闹钟数组
    for (UILocalNotification *localNotification in [ClockHelper sharedClockHelper].notificationArray) {
        NSDate *currentDate  = [[ClockHelper sharedClockHelper] getCustomDateWithHour:[time integerValue]];
        if ([localNotification.fireDate isEqualToDate:currentDate]) {
            //取消这个通知
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
    
}


#pragma mark CLLocationManagerDelegate
//更新位置
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    BOOL isBackground = NO;
    
    //存储用户位置和当前时间到数据库中
    [self saveCurrentLoaction:locations];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        isBackground = YES;
    }
    
    //进入后台进行的操作
    if (isBackground) {
        
        //存储用户位置和当前时间到数据库中
        [self saveCurrentLoaction:locations];
        
        UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            
        }];
        
    }
    
    
}

#pragma mark 保存当前用户位置
-(void)saveCurrentLoaction:(NSArray *)locations{
    //获取最新位置
    CLLocation *currentLocation = [locations lastObject];
    
    //根据最新位置,进行地理反编码
    CLGeocoder *gecoder = [CLGeocoder new];
    
    
    [gecoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        //获取用户当前位置信息
        NSString *userLocationInfo = [[placemarks lastObject] name];
        
        NSDate *currentDate = [NSDate date];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        //得到日期--字符串
        NSString *date = [dateFormatter stringFromDate:currentDate];
        
        //得到时间--字符串
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSString *time = [dateFormatter stringFromDate:currentDate];
        
        
        //判断数据是否有相同的
        
        //取出之前数据库中的数据
        NSArray *guijiArray = [[TrailHelper sharedTrailHelper] filterMapInfoDataByDate:date];
        
        TrailHelper *trailHelper = [TrailHelper sharedTrailHelper];
        
        if (guijiArray.count == 0) {
            
            //存入数据库
            [trailHelper saveMapInfoWithTime:time date:date andLocationName:userLocationInfo];
        }else{
            
            //当前时间的小时段一样
            NSString *currentHour = [time substringToIndex:2];
            
            BOOL isExist = NO;
            
            for (int count = 0; count < guijiArray.count; count ++) {
                //数组中第count个元素的小时
                NSString *countHour = [[guijiArray[count] time] substringToIndex:2];
                
                //地名为空不存，时间相同不存.整点时间段相同且地名相同的不存
                if (userLocationInfo == NULL || [[guijiArray[count] time] isEqualToString:time] || ([countHour isEqualToString:currentHour] && [[guijiArray[count] locationName] isEqualToString:userLocationInfo])) {
                    
                    isExist = YES;
                    break;
                }else{
                    continue;
                }
            }
            if (isExist == NO) {
                [trailHelper saveMapInfoWithTime:time date:date andLocationName:userLocationInfo];
            }
            
            
        }
        
        
    }];
    
}



#pragma mark - 程序将要进入后台
- (void)applicationWillResignActive:(UIApplication *)application {
  


}

#pragma mark 程序进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // 收回盒子方法
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
    scheduleHelper.scheduleArray = [scheduleHelper gainAllData];
    
    // 将showBox 设置为 NO  收回盒子
    for (int i = 0; i <= scheduleHelper.scheduleArray.count - 1; i ++) {
        _schedule = scheduleHelper.scheduleArray[i];
        
        _schedule.showBox = [NSNumber numberWithBool:NO];
        
        [scheduleHelper.appDelegate.managedObjectContext save:nil];
    }

    
    
    //开启基站定位
    [self.locationManager startMonitoringSignificantLocationChanges];

}
#pragma mark 进入前台后设置消息信息
- (void)applicationWillEnterForeground:(UIApplication *)application {
  [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
}

#pragma mark 程序进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //取消基站定位
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    //开启Wifi定位
    [self.locationManager startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
   
    [self saveContext];
}

#pragma mark -- 处理内存警告问题
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "lanou.3g.com.GUIJILIFE" in the application's documents directory.
    NSLog(@"----数据库位置 %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GUIJI_LIFE" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GUIJILIFE.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
