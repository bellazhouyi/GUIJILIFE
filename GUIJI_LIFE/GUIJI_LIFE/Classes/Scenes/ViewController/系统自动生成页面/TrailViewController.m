//
//  TrailViewController.m
//  GUIJILIFE
//
//  Created by lanou3g on 15/11/9.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "TrailViewController.h"
#import "Trail_UpCell.h"
#import "Trail_DownCell.h"
@interface TrailViewController ()<UITableViewDelegate,UITableViewDataSource>

// UITableView 的实例
@property(nonatomic,strong)UITableView *tableView;

//用于存储MapInfo的数组
@property(nonatomic,strong) NSMutableArray *arrayMapInfo;


@end

@implementation TrailViewController

static NSString *upCellID = @"cellUp_Identifier";
static NSString *downCellID = @"cellDown_Identifier";

#pragma mark 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma mark 显示
    
    // 初始化TableView
    self.tableView = [UITableView new];
    
    // 将tableView 添加到View上
    [self.view addSubview:self.tableView];
    
    
    // 设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"Trail_UpCell" bundle:nil] forCellReuseIdentifier:upCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"Trail_DownCell" bundle:nil] forCellReuseIdentifier:downCellID];
    
    // tableView 逆时针旋转90度
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    
    // 创建一个imageView
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg5"]];
    
    // 将imageView 设置为tableView 的背景视图
    self.tableView.backgroundView = imageView;
    
    // 设置tableView 的大小
    self.tableView.frame = self.view.bounds;
    
    // scrollbar 不显示
    self.tableView.showsVerticalScrollIndicator = NO;
    
    // 隐藏cell 分割线
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    //禁止tableView 回弹
//    self.tableView.bounces = NO;
    
    
}

#pragma mark 加载跟规定的时间点相同的MapInfo数据
-(void)loadData{
    
    TrailHelper *trailHelper = [TrailHelper sharedTrailHelper];
    
    //得到指定的日期
    NSString *specifiedDate = self.date;
    
    NSDate *currentDay = [NSDate date];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currentDateStr = [formatter stringFromDate:currentDay];
    
    //如果是当天的需要删除某些数据，如果是前几天的就直接取就可以了。
    if ([currentDateStr isEqualToString:specifiedDate]) {
        
        //从数据库中得到同一天的用户轨迹相关信息
        NSArray *allMapInfo = [trailHelper removeDataWithSimpleDataByDate:specifiedDate];
        
        //得到刷选后的数据--这些数据已经是移除相同时间同一位置后的。
        self.arrayMapInfo = [NSMutableArray arrayWithArray:allMapInfo];
    }else{
        self.arrayMapInfo = [NSMutableArray arrayWithArray:[trailHelper filterMapInfoDataByDate:specifiedDate]];
    }
    
}

#pragma mark - 禁止屏幕旋转
- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark - UITableViewDelegate UITableViewDataSource

#pragma mark 添加一个HeaderView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 667)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:247 / 255.0 green:267 / 255.0 blue:202 / 255.0 alpha:1] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    headerView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    backButton.frame = CGRectMake(10, 40, 50, 50);
    
    [headerView addSubview:backButton];
    
    //添加日期
    CGFloat lableY = tableView.center.y;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,lableY - 25, 50, 50)];
    label.text = self.date;
    label.numberOfLines = 0;
    [headerView addSubview:label];
    
    
    return headerView;
}

#pragma mark 返回按钮的返回事件
-(void)backAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 设置cell 的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayMapInfo.count;
}

#pragma mark - cell 的行内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row % 2) == 0) {
        Trail_UpCell *upCell = [tableView dequeueReusableCellWithIdentifier:upCellID forIndexPath:indexPath];
        
        
        // cell 顺时针旋转90度
        upCell.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        // 设置 cell 的背景颜色为透明
        upCell.backgroundColor = [UIColor clearColor];
        
        //把数据填充到upCell上
        MapInfo *upMapInfo = self.arrayMapInfo[indexPath.row];
        
        NSString *message = [NSString stringWithFormat:@"%@ -> %@",upMapInfo.time,upMapInfo.locationName];
        
        upCell.UPLabel.text = message;
       
        
        
        return upCell;
    }else{
        Trail_DownCell *downCell = [tableView dequeueReusableCellWithIdentifier:downCellID forIndexPath:indexPath];
        
        // cell 顺时针旋转90度
        downCell.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        // 设置 cell 的背景颜色为透明
        downCell.backgroundColor=[UIColor clearColor];
        
        //把数据填充到upCell上
        MapInfo *downMapInfo = self.arrayMapInfo[indexPath.row];
        

        NSString *message = [NSString stringWithFormat:@"%@ -> %@",downMapInfo.time,downMapInfo.locationName];
        
        downCell.DownLabel.text = message;
        

        
        return downCell;
    }
}

#pragma mark - 设置cell 高度（因为cell是旋转了90度，所以其实是设置cell的宽度）
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - 给HeaderView一个宽度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}



#pragma mark 接收date的值
-(void)setDate:(NSString *)date{
    _date = date;
    
     // 获取数据
    [self loadData];
}





@end
