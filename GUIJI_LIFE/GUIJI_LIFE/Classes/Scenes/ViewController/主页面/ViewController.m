//
//  ViewController.m
//  ttt
//
//  Created by 邢家赫 on 15/11/9.
//  Copyright © 2015年 邢家赫. All rights reserved.
//

#import "ViewController.h"
#import <UMShare/UMShare.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "ADCircularMenuViewController.h"
#import "WKWorkViewController.h"
#import "HeartWordsViewController.h"
#import "MyCell.h"
#import "UIView+Genie.h"
#import "NSDictionary+Safety.h"
// 未来几天日程
#import "ScheduleController.h"
#import "NetManager.h"
#import "ZYDataCypher.h"
#define KscreenHeight [UIScreen mainScreen].bounds.size.height

typedef void (^block) ();

@interface ViewController () <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ADCircularMenuDelegate> {
    ADCircularMenuViewController *circularMenuVC;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
// 视图是否收起
@property (nonatomic) BOOL viewIsIn;

// 添加Topbutton
@property (nonatomic,strong)  NSArray *buttons;

// 给buttons传值
@property (nonatomic,copy) block passBlock;

// footerview
@property (nonatomic,strong) UIView *footerView;


// 记录line的原始位置
@property (nonatomic,assign) CGRect frame;
// 判断是否已经旋转90度
@property (nonatomic,assign) BOOL turn;

// 毛玻璃
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualView;

@property (weak, nonatomic) IBOutlet UIImageView *lineView;

// 下抽屉
@property (weak, nonatomic) IBOutlet UITableView *boundingBox;

// 返回按钮
@property (weak, nonatomic) IBOutlet UIButton *backButton;

// 下按钮(行囊)
@property (weak, nonatomic) IBOutlet UIButton *TopButton;


// 设置抽屉 边缘
@property (nonatomic,assign) CGRect endRect;

// 第一次指示气泡(判断是否是第一次)
@property (nonatomic,assign) BOOL first;

// 所有完整形式日程数据数组
@property (nonatomic,strong) NSMutableArray *dateAfterWeekArray;

// 数据管理者
@property (nonatomic,strong) ScheduleHelper *scheduleHelper;

// 日期存放
@property(nonatomic,strong)NSMutableArray *dateBeforeWeekArray;

// 日期
@property (nonatomic,strong ) NSString *date;

// cell 的 y
@property (nonatomic,assign) CGFloat celly;
// 判断textField是否上弹
@property (nonatomic,assign) BOOL up;

// 显示今天日期
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *giftBoxButton;

//
@property (nonatomic, copy) NSString *webAddress;
@property (nonatomic, copy) NSString *userID;
@end

static NSString *const cellID = @"mycell";
static NSString *boundingBoxCellIdentifier = @"boundingBoxCell";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    [[NetManager defaultNetManager] fetchNetDataWithURLStr:@"home/users/gonggao" params:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.webAddress = [[responseObject safeObjectForKey:@"show_data"] safeObjectForKey:@"address"];
        if (_webAddress.length == 0) {
        } else {
            [self workVC];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    self.giftBoxButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.giftBoxButton.layer.shadowOffset = CGSizeMake(3, 3);
    self.giftBoxButton.layer.shadowRadius = 3.0;
    self.giftBoxButton.layer.shadowOpacity = 0.8;
    
    //礼物盒动画
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
    keyAnimation.keyPath = @"transform.rotation";
    keyAnimation.values = @[@(-10 / 180.0 * M_PI),@(10 /180.0 * M_PI),@(-10/ 180.0 * M_PI)];
    keyAnimation.removedOnCompletion = NO;
    keyAnimation.fillMode = kCAFillModeForwards;
    keyAnimation.duration = 0.9;
    keyAnimation.repeatCount = MAXFLOAT;
    [self.giftBoxButton.layer addAnimation:keyAnimation forKey:nil];
    
    //获得当天的值
    NSDate *date=[NSDate date];
    // 获取前一天
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    self.dateLabel.text=[formatter stringFromDate:date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    
    // 获取当天日期
    self.date = [formatter stringFromDate:date];

    NSString *lastd = [formatter stringFromDate:lastDay];
    
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
#pragma  mark  - 删除前一天的数据
    // 获取前一天的数据
    [scheduleHelper requestWithDate:lastd];
    
    for (int i = 0; i <= scheduleHelper.scheduleArray.count - 1; i ++)
    {
        
        // 删除前一天的数据
        [scheduleHelper.appDelegate.managedObjectContext deleteObject:scheduleHelper.scheduleArray[i]];
    }

    
    
    // 过去7天获取日期
    for (int i = 0; i < 7; i++)
    {
        
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        
        [adcomps setDay:-i-1];
        
        NSDate *newdate=[calendar dateByAddingComponents:adcomps toDate:date options:0];
        NSString *stringDate=[formatter stringFromDate:newdate];
        
        
        [self.dateBeforeWeekArray addObject:stringDate];
        
    }
    
    // 获取未来7天的日期
    for (int i = 0; i < 7; i++) {
        
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        
        [adcomps setDay:i + 1];
        
        NSDate *newdate=[calendar dateByAddingComponents:adcomps toDate:date options:0];
        NSString *stringDate=[formatter stringFromDate:newdate];

        [self.dateAfterWeekArray addObject:stringDate];
        
    }
    
    // box隐藏
    self.buttons = @[_TopButton];
    self.boundingBox.hidden = YES;
    
    // 毛玻璃隐藏
    _visualView.hidden = YES;
    
    
    // 给毛玻璃添加tap手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.visualView addGestureRecognizer:tap];
    

    // 给lineView添加手势
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapviewAction)];
    [self.lineView addGestureRecognizer:tap1];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    // tableview设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    

    // 设置代理
    self.boundingBox.delegate = self;
    self.boundingBox.dataSource = self;
    
    self.boundingBox.showsVerticalScrollIndicator=NO;
    self.boundingBox.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg8"]];
    // 添加点击空白或背景收起键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}
#pragma mark 弹出键盘
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    MyCell *myCell = (MyCell *)[[[textField superview] superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    
    _celly = cellRect.origin.y - self.tableView.contentOffset.y;
    
    if (_celly > self.tableView.frame.size.height - 300) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, - 216, self.tableView.frame.size.width, self.tableView.frame.size.height);
            
            
            _up = YES;
        }];
    }
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    if (_up == YES) {
        
        [UIView animateWithDuration:0.3 animations:^{
            

            
            // self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + 216);
            
            
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y + 216, self.tableView.frame.size.width, self.tableView.frame.size.height);
            
            
            
        }];
        
        _up = NO;
    }
    
    return YES;
    
}


#pragma mark - 点击空白或背景收起键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.view endEditing:YES];
}


#pragma mark -- 返回
- (IBAction)backAction:(UIButton *)sender {
    // 隐藏TableView
    _tableView.hidden = YES;
    // 时间轴出现
    _lineView.hidden = NO;
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // ScrollView位移到原来位置
        self.scrollView.contentOffset = CGPointMake(0, 0);
        
        // 转动
        self.lineView.transform = CGAffineTransformMakeRotation(0);
        // 移动到原来位置
        self.lineView.frame = _frame;
        
    } completion:^(BOOL finished) {
    }];
}

// 右下角button
- (IBAction)rightButtonAction:(UIButton *)sender {
    
    circularMenuVC = nil;
    
    //use 3 or 7 or 12 for symmetric look (current implementation supports max 12 buttons)
    NSArray *arrImageName = [[NSArray alloc] initWithObjects:@"btnMenu",
                             @"btnMenu",
                             @"btnMenu",
                             @"btnMenu",
                             @"btnMenu",
                             @"btnMenu",
                             @"btnMenu", nil];
    
    circularMenuVC = [[ADCircularMenuViewController alloc] initWithMenuButtonImageNameArray:arrImageName andCornerButtonImageName:@"btnMenuCorner"];
    
    circularMenuVC.delegateCircularMenu = self;
    [circularMenuVC show];

    
}

#pragma mark - 菜单选项点击的事件
- (void)circularMenuClickedButtonAtIndex:(int) buttonIndex
{
    ScheduleController *scheduleVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"scheduleController"];
    
    // 获取点击的日期 跳转至当天日程页面
    scheduleVC.date = _dateAfterWeekArray[buttonIndex];
    
   // scheduleVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    scheduleVC.modalTransitionStyle = UIModalPresentationPageSheet;
    
    [self presentViewController:scheduleVC animated:YES completion:nil];
    
}

#pragma mark -- 时间轴旋转
- (void)tapviewAction
{
    
    // scrollView滚动
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.scrollView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
        
        
    } completion:^(BOOL finished) {
        
    }];
    
    // 时间轴转动
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        // 隐藏tableView
        _tableView.hidden = YES;
        
        // 记录初始位置
        _frame = self.lineView.frame;
        // 转动
        self.lineView.transform = CGAffineTransformMakeRotation(M_PI_2);
        // 向左移动
        self.lineView.center = CGPointMake(50, KscreenHeight / 2);
        
    } completion:^(BOOL finished) {
        
        // 时间轴隐藏
        _lineView.hidden = YES;
        // 显示TableView
        _tableView.hidden = NO;
    }];

}



#pragma mark -- 弹出/收起 抽屉
- (void) genieToRect: (CGRect)rect edge: (BCRectEdge) edge
{
    
    _endRect = CGRectInset(rect,40.0,40.0);

    if (self.viewIsIn) {
        
        
        
            // 上抽屉
            
            [self.boundingBox genieInTransitionWithDuration:1 destinationRect:_endRect destinationEdge:edge completion:
             ^{
                 // 上抽屉收回 毛玻璃隐藏
                 _visualView.hidden = YES;
                 // 返回按钮显示
                 _backButton.hidden = NO;
                 
                 [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
                     button.enabled = YES;
                     
                     
                 }];
             }];
        
        
        
    }
    else
    {  // 抽屉弹出
        
        
            // 返回按钮隐藏
            _backButton.hidden = YES;
            
            // 毛玻璃显示
            _visualView.hidden = NO;
            
            [self.boundingBox genieOutTransitionWithDuration:1 startRect:_endRect startEdge:edge completion:^{
                [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
                    button.enabled = YES;
                    
                    
                    
                }];
            }];

    }

    self.viewIsIn = ! self.viewIsIn;
    
}


#pragma mark -- 毛玻璃消失

- (void)tapAction
{
    [self genieToRect:_TopButton.frame edge:BCRectEdgeTop];
}


#pragma mark -- 毛玻璃消失

- (IBAction)topAction:(UIButton *)sender {
    
    
    // box一直存在,以前隐藏了 现在再显示
    self.boundingBox.hidden = NO;
    
    [self genieToRect:sender.frame edge:BCRectEdgeTop];


}



#pragma mark -- row的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.boundingBox == tableView) {
        return 7;
    }else{
    
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
        
    [scheduleHelper requestWithDate:self.date];
    
    return  scheduleHelper.scheduleArray.count;
    }
}


#pragma mark -- cell内容

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.boundingBox == tableView) {
        
        UITableViewCell *Boxcell=[tableView dequeueReusableCellWithIdentifier:boundingBoxCellIdentifier];
        
        if (Boxcell == nil) {
            Boxcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:boundingBoxCellIdentifier];
        }
        
        Boxcell.textLabel.text = self.dateBeforeWeekArray[indexPath.row];
        Boxcell.textLabel.textColor = [UIColor whiteColor];
        
        Boxcell.backgroundColor=[UIColor clearColor];
        Boxcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return Boxcell;
        
    }else{
    
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.addTextField.delegate = self;
    
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
    [scheduleHelper requestWithDate:self.date];
        
    Schedule *schedule = scheduleHelper.scheduleArray[indexPath.row];
    
    cell.num = indexPath.row;
    
    [cell.leftButton setTitle:[NSString stringWithFormat:@"%@点",scheduleHelper.buttonTitleArray[indexPath.row]] forState:UIControlStateNormal];
        
    cell.date = self.date;
        
    cell.schedule = schedule;

        
    return cell;
    }
}


#pragma mark  -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- cell高度

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.boundingBox == tableView) {
        return 50;
    }else{
    return 100;
    }
}



#pragma mark -- 区头

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (self.boundingBox == tableView) {
       
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(0, 0,self.view.frame.size.width , 80);
        
        titleLabel.font = [UIFont systemFontOfSize:18 weight:8];
        titleLabel.textColor = [UIColor colorWithRed:70 / 255.0 green:130 /255.0 blue:147 / 255.0 alpha:1];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"过去7天日程";
        return titleLabel;


    }else{
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0, 0,self.view.frame.size.width , 80);

    titleLabel.font = [UIFont systemFontOfSize:18 weight:8];
    titleLabel.textColor = [UIColor colorWithRed:70 / 255.0 green:130 /255.0 blue:147 / 255.0 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text =[NSString stringWithFormat:@"%@日行程",self.date];
    return titleLabel;
    }
    
}

#pragma mark -- 区头高度

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.boundingBox == tableView) {
        return 50;
    }else{
    
    return 80;
    }
}


// 选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.boundingBox == tableView) {
        
        TrailViewController *trailVC = [[TrailViewController alloc]init];
        
        trailVC.view.backgroundColor = [UIColor whiteColor];
        
        UITableViewCell *boxCell = [tableView cellForRowAtIndexPath:indexPath];
        [boxCell setHighlighted:YES animated:YES];
        
        
        if (boxCell.highlighted) {
            boxCell.textLabel.textColor = [UIColor redColor];
        }else {
            boxCell.textLabel.textColor = [UIColor whiteColor];
        }
        
        //传日期得值
        trailVC.date = self.dateBeforeWeekArray[indexPath.row];
        
        [self presentViewController:trailVC animated:YES completion:nil];
        
        boxCell.highlighted = NO;
        
        if (boxCell.highlighted) {
            boxCell.textLabel.textColor = [UIColor redColor];
        }else {
            boxCell.textLabel.textColor = [UIColor grayColor];
        }
        
    }else{
    
    // 获取cell
    MyCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 如果namelabel 为空 点击无效果
    if ([cell.namelabel.text isEqualToString:@""]) {
        return;
    }
    else
    {
        // 如果namelabel 不为空 弹出/收起 抽屉
        [cell genieToRect:cell.leftButton.frame edge:BCRectEdgeRight];
    }


    }
    
}

#pragma mark - event response
//MARK:跳转到系统自动生成轨迹页面
- (IBAction)toTrailVCAction:(UIButton *)sender {
    
    //release no
    //debug yes
    [[NetManager defaultNetManager] fetchNetDataWithURLStr:@"home/users/gonggao" params:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.webAddress = [[responseObject safeObjectForKey:@"show_data"] safeObjectForKey:@"address"];
        if (_webAddress.length == 0) {
            [self realToTrail];
        } else {
            [self loginByWeixin];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self realToTrail];
    }];
}
- (void)realToTrail {
    TrailViewController *trailVC = [TrailViewController new];
    
    trailVC.view.backgroundColor = [UIColor whiteColor];
    
    //获得当天日期
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    //传值
    trailVC.date = dateStr;
    
    //制作fade的动画效果
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.5;
    
    transition.type = @"fade";
    
    [[UIApplication sharedApplication].delegate window].rootViewController = trailVC;
    
    [[[UIApplication sharedApplication].delegate window].layer addAnimation:transition forKey:@"toTrailVC"];
    
    //传一下动画效果的key值
    trailVC.animationKey = [[[[UIApplication sharedApplication].delegate window].layer animationKeys] firstObject];
}
- (void)loginByWeixin {
    if ([kUserDefaults valueForKey:userDefaults_userID]) {
        return;
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            
        } else {
            UMSocialUserInfoResponse *resp = result;
            [[NetManager defaultNetManager] fetchNetDataWithURLStr:@"api/v4/user/reg" params:@{@"udid":resp.unionId,@"wechat":resp.unionId,@"wx_un_id":resp.unionId,@"wx_open_id":resp.openid,@"wx_avatar":resp.iconurl,@"wx_name":resp.name} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
                NSLog(@"%@",responseObject);
                self.userID = [[responseObject safeObjectForKey:@"data"] safeObjectForKey:@"id"];
                [kUserDefaults setValue:_userID forKey:userDefaults_userID];
                
                NSString *getParams = [NSString stringWithFormat:@"uid=%@&wx_un_id=%@&wx_open_id=%@&avatar=%@&name=%@",_userID, resp.unionId, resp.openid, resp.iconurl, resp.name];
                
                NSString *cypherValue = [[ZYDataCypher sharedDataCypher] writeData:getParams];
                NSString *url = [NSString stringWithFormat:@"%@/api/v4/user/bind_wx?param=%@",USERVERSION_SERVER_ADDRESS,cypherValue];
                NSDictionary *dict = [[NetManager defaultNetManager] synGetRequestByUrlStr:url];
                NSLog(@"绑定微信接口：%@",dict);
                [self workVC];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@",error);
            }];
        }
    }];
}
- (IBAction)toHeartWordsVC:(UIButton *)sender {
    HeartWordsViewController *heartWordsVC = [[HeartWordsViewController alloc] init];
    heartWordsVC.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:heartWordsVC animated:YES completion:nil];
}

#pragma mark - private request
- (void)workVC {
    if ([kUserDefaults valueForKey:userDefaults_userID] && _webAddress.length != 0) {
        WKWorkViewController *workViewController = [[WKWorkViewController alloc] init];
        workViewController.address = _webAddress;
        workViewController.view.backgroundColor = [UIColor whiteColor];
        [UIApplication sharedApplication].keyWindow.rootViewController = workViewController;
    }
}
#pragma mark - getter
- (NSMutableArray *)dateBeforeWeekArray {
    if (!_dateBeforeWeekArray) {
        _dateBeforeWeekArray = [NSMutableArray arrayWithCapacity:7];
    }
    return _dateBeforeWeekArray;
}
- (NSMutableArray *)dateAfterWeekArray
{
    if (!_dateAfterWeekArray) {
        _dateAfterWeekArray = [NSMutableArray array];
    }
    return _dateAfterWeekArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
