//
//  PackCell.m
//  GUIJI_LIFE
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 周屹. All rights reserved.
//

#import "PackCell.h"

@implementation PackCell

- (void)awakeFromNib {
    // Initialization code
    
    
    UIColor *color=[UIColor colorWithPatternImage:[UIImage imageNamed:@"5"]];
    [self.label setBackgroundColor:color];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
