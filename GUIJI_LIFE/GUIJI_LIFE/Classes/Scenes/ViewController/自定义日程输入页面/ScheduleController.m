//
//  ScheduleController.m
//  GUIJI_LIFE
//
//  Created by 邢家赫 on 15/11/14.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "ScheduleController.h"
#import "NextCell.h"
#import "MyCell.h"
@interface ScheduleController ()

@end

static NSString *const cellID = @"cell_ID";

@implementation ScheduleController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    CGRect rect = [[self view] bounds];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:[UIImage imageNamed:@"love" ]];
    
//    [self.view setBackgroundColor:[UIColor clearColor]];   //(1)
//    self.tableView.opaque = NO; //(2) (1,2)两行不要也行，背景图片也能显示
    self.tableView.backgroundView = imageView;
    
    
//    [self.tableView registerClass:[NextCell class] forCellReuseIdentifier:cellID];
//
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellReuseIdentifier:cellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    return scheduleHelper.scheduleArray.count;
}

// 显示cell内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];

    
    
    //cell.addTextField.delegate = self;
    
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
    Schedule *schedule = scheduleHelper.scheduleArray[indexPath.row];
    
    cell.num = indexPath.row;
    
    cell.schedule = schedule;

    
    
    return cell;
}

// 选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取cell
    MyCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 如果namelabel 为空 点击无效果
    
    NSLog(@"----%ld",indexPath.row);
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

// 区头高度
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
    titleLabel.frame = CGRectMake(80, 0, 200, 80);
    titleLabel.textColor = [UIColor purpleColor];
    titleLabel.text = @"为你的行程填上一笔";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:titleLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(10, 30, 40, 30);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTintColor:[UIColor orangeColor]];
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];

    [headerView addSubview:button];
    
    return headerView;
    
    
}

- (void)backAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
