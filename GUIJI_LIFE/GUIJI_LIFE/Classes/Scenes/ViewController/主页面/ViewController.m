//
//  ViewController.m
//  ttt
//
//  Created by 邢家赫 on 15/11/9.
//  Copyright © 2015年 邢家赫. All rights reserved.
//

#import "ViewController.h"
#import "MyCell.h"
#import "UIView+Genie.h"
#import <QuartzCore/QuartzCore.h>
#import "TripViewController.h"
#import "ADCircularMenuViewController.h"
// 未来几天日程
#import "ScheduleController.h"

#define KscreenHeight [UIScreen mainScreen].bounds.size.height

typedef void (^block) (void);

@interface ViewController () <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ADCircularMenuDelegate>
{
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
@property (nonatomic,strong) NSMutableArray *dateArray;

// 数据管理者
@property (nonatomic,strong) ScheduleHelper *scheduleHelper;

// 日期存放
@property(nonatomic,strong)NSMutableArray *dateAllArray;

// 日期
@property (nonatomic,strong ) NSString *date;

// cell 的 y
@property (nonatomic,assign) CGFloat celly;
// 判断textField是否上弹
@property (nonatomic,assign) BOOL up;

// 显示今天日期
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

static NSString *const cellID = @"mycell";
static NSString *boundingBoxCellIdentifier = @"boundingBoxCell";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获得当天的值
    NSDate *date=[NSDate date];
    // 获取前一天
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    self.dateLabel.text=[formatter stringFromDate:date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comps = nil;
    
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    // 前一天的时间
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:lastDay];
    
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
        
        
        [self.dateAllArray addObject:stringDate];
        
    }
    
    // 获取未来7天的日期
    for (int i = 0; i < 7; i++) {
        
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        
        [adcomps setDay:i + 1];
        
        NSDate *newdate=[calendar dateByAddingComponents:adcomps toDate:date options:0];
        NSString *stringDate=[formatter stringFromDate:newdate];

        [self.dateArray addObject:stringDate];
        
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
    
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

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
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
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
    scheduleVC.date = _dateArray[buttonIndex];
    
   // scheduleVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    scheduleVC.modalTransitionStyle = UIModalPresentationPageSheet;
    
    [self presentViewController:scheduleVC animated:YES completion:nil];
    
}




#pragma mark -- 旋转
- (void)tapviewAction
{
    // scrollView滚动
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.scrollView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
        
        
    } completion:^(BOOL finished) {
        NSLog(@"11动画完成了");
        
        
    }];
    
    
    // 时间轴转动
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        
        // 记录初始位置
        _frame = self.lineView.frame;
        // 转动
        self.lineView.transform = CGAffineTransformMakeRotation(M_PI_2);
        // 向左移动
        self.lineView.center = CGPointMake(50, KscreenHeight / 2);
        
        
        
        
    } completion:^(BOOL finished) {
        NSLog(@"动画完成了");
        
        // 时间轴隐藏
        _lineView.hidden = YES;
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
    
        NSLog(@"-------%ld",scheduleHelper.scheduleArray.count);
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
        
        Boxcell.textLabel.text = self.dateAllArray[indexPath.row];
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

    
        cell.namelabel.numberOfLines=0;
        cell.namelabel.preferredMaxLayoutWidth=CGRectGetWidth(cell.namelabel.bounds);
        
        // 执行block
        cell.block = ^(){
            [tableView reloadData];
        };
        
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
        return 45;
    }else{
    return UITableViewAutomaticDimension;
    }
}



#pragma mark -- 区头

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (self.boundingBox == tableView) {
       
        return nil;

    }else{
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(160, 0,self.view.frame.size.width - 60, 80);
    titleLabel.textColor = [UIColor orangeColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text =[NSString stringWithFormat:@"为你%@日的行程添上一笔",self.date];
    return titleLabel;
    }
    
}

#pragma mark -- 区头高度

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.boundingBox == tableView) {
        return 0;
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
        
        //传日期得值
        trailVC.date = self.dateAllArray[indexPath.row];
        
        [self presentViewController:trailVC animated:YES completion:nil];
        
        
        
        
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


#pragma mark - 懒加载
- (NSMutableArray *)dateArray
{
    if (!_dateArray) {
        _dateArray = [NSMutableArray array];
    }
    return _dateArray;
}


#pragma mark -跳转到系统自动生成轨迹页面
- (IBAction)toTrailVCAction:(UIButton *)sender {
    
    TrailViewController *trailVC = [TrailViewController new];
    
    trailVC.view.backgroundColor = [UIColor whiteColor];
    
    //获得当天日期
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    //传值
    trailVC.date = dateStr;
    
    
    [self presentViewController:trailVC animated:YES completion:nil];
    
}

#pragma mark - dateAllArray 懒加载
- (NSMutableArray *)dateAllArray
{
    if (!_dateAllArray) {
        self.dateAllArray=[NSMutableArray array];
    }
    return _dateAllArray;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
