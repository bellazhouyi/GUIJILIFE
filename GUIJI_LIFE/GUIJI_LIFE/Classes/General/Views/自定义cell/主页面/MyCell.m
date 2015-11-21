//
//  MyCell.m
//  te
//
//  Created by 邢家赫 on 15/11/9.
//  Copyright © 2015年 邢家赫. All rights reserved.
//

#import "MyCell.h"

@interface MyCell () 

// 视图是否收起
@property (nonatomic) BOOL viewIsIn;

@property (nonatomic,strong) NSArray *buttons;

@end


@implementation MyCell


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        // 注册notification
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:self.addTextField];
        
    }
    return self;
}


#define kMaxLength 50
// 实现监听方法
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}


// 在dealloc里注销掉监听方法
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.addTextField];
}
// 闹钟开关按钮
- (IBAction)ClockAction:(UISwitch *)sender {
    
    // 如果闹钟提醒关闭 就开启
    if (self.clockSwitch.on == YES) {
        
        self.clockLabel.text = @"闹钟已开启";
    }
    else
    {
        self.clockLabel.text = @"闹钟已关闭";
    }
    
    // 单例
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    // 获取日期
    [scheduleHelper requestWithDate:self.date];
    

    // 把schedule模型保存进数据库
    _schedule =  scheduleHelper.scheduleArray[self.num] ;
    
    // 接收闹钟开关的状态
    _schedule.isClock = [NSNumber numberWithBool:self.clockSwitch.on];
    
    [scheduleHelper.appDelegate.managedObjectContext save:nil];
    
    
    NSString *hour = [NSString stringWithFormat:@"%@",_schedule.hour];
    //关于闹钟---开启闹钟通知
    if ([_schedule.isClock boolValue] == YES) {
        //写一个通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"clock" object:nil userInfo:@{@"time":hour,@"content":_schedule.content}];
    }else{
        //否则，关闭闹钟通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notClock" object:nil userInfo:@{@"time":hour}];
    }
    
}


// 添加完成
- (IBAction)addDownAction:(UIButton *)sender {
    
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];
    
    // 申请数据
    [scheduleHelper requestWithDate:self.date];
    
    _schedule = scheduleHelper.scheduleArray[self.num];

    
    // 把文本框内容给cell
    
    self.namelabel.text = self.addTextField.text;

    // 收回抽屉
    [self genieToRect:self.leftButton.frame edge:BCRectEdgeRight];
    
    // 如果namelabel 不为空 就显示气泡图片
    if ([self.namelabel.text isEqualToString:@""]) {
        
        self.bubbleimage.hidden = YES;
        
        // 如果隐藏那么 isShow = NO;
        _schedule.isShow = [NSNumber numberWithBool:NO];
    }
    else
    {
        self.bubbleimage.hidden = NO;
        
        // 如果不隐藏 那么isShow = YES;
        _schedule.isShow = [NSNumber numberWithBool:YES];
    }
    

    // 保存namelabel 给 content
    _schedule.content = self.addTextField.text;
    

    // 保存修改
    NSError *error = nil;

    [scheduleHelper.appDelegate.managedObjectContext save:&error];

    
    
    
}




// 点击按钮 弹出左抽屉
- (IBAction)leftButtonAction:(UIButton *)sender {
    

    // 弹出 / 收起抽屉方法
    [self genieToRect:sender.frame edge:BCRectEdgeRight];

    
}

// 弹出/收起 抽屉
- (void) genieToRect: (CGRect)rect edge: (BCRectEdge) edge
{
    // 单例
    ScheduleHelper *scheduleHelper = [ScheduleHelper sharedDatamanager];

    // 数据库申请数据
    [scheduleHelper requestWithDate:self.date];
    
    // 获取 cell的 索引
    _schedule = scheduleHelper.scheduleArray[self.num];

    
    // 设置抽屉 边缘
    CGRect endRect = CGRectInset(rect,self.leftButton.frame.size.width / 2 - 1,self.leftButton.frame.size.height / 2 - 1);
    
    
    if (self.viewIsIn) {
        
        
        
        // 抽屉收起
        
        [self.leftBox genieInTransitionWithDuration:0.8 destinationRect:endRect destinationEdge:edge completion:
         ^{

             // 把文本框内容给cell

             self.namelabel.text = self.addTextField.text;
             
             [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
                 
                 button.enabled = YES;
                 
                 
             }];
         }];
        // 如果namelabel 不为空 就显示气泡图片
        if ([self.namelabel.text isEqualToString:@""]) {
            
            self.bubbleimage.hidden = YES;
            
            // 如果隐藏那么 isShow = NO;
            _schedule.isShow = [NSNumber numberWithBool:NO];
        }
        else
        {
            self.bubbleimage.hidden = NO;
            
            // 如果不隐藏 那么isShow = YES;
            _schedule.isShow = [NSNumber numberWithBool:YES];
        }

        
        
        // 抽屉收起 showBox = NO;
        _schedule.showBox = [NSNumber numberWithBool:NO];
        
        
    }
    else
    {
        // 把cell内容给文本框

        self.addTextField.text = self.namelabel.text;
        
        
        
        // 抽屉弹出
        // box一直存在,以前隐藏了 现在再显示
        self.leftBox.hidden = NO;
        
        [self.leftBox genieOutTransitionWithDuration:0.8 startRect:endRect startEdge:edge completion:^{
            [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
                button.enabled = YES;
                
                
                
            }];
        }];
        // 抽屉弹出  showBox = YES;
        _schedule.showBox = [NSNumber numberWithBool:YES];
    }
    
    // 保存修改
    NSError *error = nil;
    
    [scheduleHelper.appDelegate.managedObjectContext save:&error];
    
    self.viewIsIn = ! self.viewIsIn;
    

    
}



#pragma mark schedule 的 setter方法

- (void)setSchedule:(Schedule *)schedule
{
    self.namelabel.text = schedule.content;
    
    NSNumber *num = [NSNumber numberWithInt:1];

    // 如果 showBox = Yes 就不隐藏
    if ([schedule.showBox isEqualToNumber:num]) {
        
        self.leftBox.hidden = NO;
    }
    else
    {
        // 否则隐藏
        self.leftBox.hidden = YES;
    }

    
    
    
    // 如果 isShow = Yes 就不隐藏
    if ([schedule.isShow isEqualToNumber:num]) {
        
        self.bubbleimage.hidden = NO;
    }
    else
    {
        // 否则隐藏
        self.bubbleimage.hidden = YES;
    }
    

    // 设置闹钟
    if ([schedule.isClock isEqualToNumber:num]) {

        self.clockSwitch.on = YES;
    }
    else
    {
        
        self.clockSwitch.on = NO;
    }
}


- (void)awakeFromNib {

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
