//
//  Trail_UpCell.m
//  GUIJI_LIFE
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "Trail_UpCell.h"

@implementation Trail_UpCell

#pragma mark - 视图加载完成
- (void)awakeFromNib {
    
    UIColor *color=[UIColor colorWithPatternImage:[UIImage imageNamed:@"5"]];
    [self.UPLabel setBackgroundColor:color];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
