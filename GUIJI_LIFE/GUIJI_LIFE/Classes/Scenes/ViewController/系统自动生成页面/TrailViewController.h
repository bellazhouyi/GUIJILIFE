//
//  TrailViewController.h
//  GUIJILIFE
//
//  Created by lanou3g on 15/11/9.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^block)();
@interface TrailViewController : UIViewController

//用于接收日期字符串
@property(nonatomic,strong) NSString *date;


//用于接收动画效果的key值
@property(nonatomic,strong) NSString *animationKey;


//声明block属性
@property(nonatomic,strong) block block;

@end
