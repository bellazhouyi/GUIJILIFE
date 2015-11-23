//
//  ScheduleController.m
//  GUIJI_LIFE
//
//  Created by 邢家赫 on 15/11/14.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "ScheduleController.h"
#import "MyCell.h"
@interface ScheduleController ()<UITextFieldDelegate>

@end

static NSString *const cellID = @"cell_ID";

@implementation ScheduleController

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置
    CGRect rect = [[self view] bounds];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:[UIImage imageNamed:@"bg6" ]];
    

    self.tableView.backgroundView = imageView;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    // 添加点击空白或背景收起键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
}

#pragma mark - 点击空白或背景收起键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.view endEditing:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // 通过日期获取数据
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
    // 数据库申请数据
    [scheduleHelper requestWithDate:self.date];
    
    return scheduleHelper.scheduleArray.count;
}

#pragma mark - 显示cell内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    
    
    cell.addTextField.delegate = self;
    
    // 通过日期获取数据
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
    // 数据库申请数据
    [scheduleHelper requestWithDate:self.date];
    
    Schedule *schedule = scheduleHelper.scheduleArray[indexPath.row];
    
    cell.num = indexPath.row;
    
    [cell.leftButton setTitle:[NSString stringWithFormat:@"%@点",scheduleHelper.buttonTitleArray[indexPath.row]] forState:UIControlStateNormal];
    
    // 获取日期
    cell.date = self.date;
    
    cell.schedule = schedule;

    
    
    return cell;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - 区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

#pragma mark -- 区头
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];

    titleLabel.frame = CGRectMake( 0, 0, self.view.frame.size.width , 80);
    titleLabel.font = [UIFont systemFontOfSize:18 weight:8];
    titleLabel.textColor = [UIColor colorWithRed:21 / 255.0 green:147 / 255.0 blue:185 / 255.0 alpha:1];
    titleLabel.text = [NSString stringWithFormat:@"%@日行程",self.date];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    [headerView addSubview:titleLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10, 25, 40, 30);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:21 / 255.0 green:147 / 255.0 blue:185 / 255.0 alpha:1]];
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];

    button.titleLabel.font = [UIFont systemFontOfSize:18 weight:8];
    
    [headerView addSubview:button];
    
    return headerView;
    
    
}

#pragma mark - 返回上一个界面
- (void)backAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
