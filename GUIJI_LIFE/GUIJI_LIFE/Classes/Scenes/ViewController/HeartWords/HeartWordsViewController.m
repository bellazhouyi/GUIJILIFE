//
//  HeartWordsViewController.m
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/9.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import "HeartWordsViewController.h"
@import WebKit;
#import <Masonry/Masonry.h>
@interface HeartWordsViewController ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation HeartWordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.backButton];
    __weak typeof(self) ws = self;
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view.mas_left).offset(15);
        make.top.equalTo(ws.view.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.webView = [[WKWebView alloc] init];
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.backButton.mas_bottom);
        make.left.equalTo(ws.view.mas_left);
        make.right.equalTo(ws.view.mas_right);
        make.bottom.equalTo(ws.view.mas_bottom);
    }];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://new.feiniuapp.com/notice?id=19"]];
    [_webView loadRequest:request];
}

#pragma mark - event response
- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:nil forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"backArrow"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end
