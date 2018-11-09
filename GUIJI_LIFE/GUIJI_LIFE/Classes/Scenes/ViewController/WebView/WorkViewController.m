//
//  WorkViewController.m
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/7.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import "WorkViewController.h"
#import <Masonry/Masonry.h>
#import <UShareUI/UShareUI.h>
#import <MJRefresh/MJRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSDictionary+Safety.h"
#import "ShareManager.h"
#import "NetManager.h"
#import "JSContextHandler.h"
@interface WorkViewController ()<UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) JSContextHandler *jsContextHandler;
@end

@implementation WorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self userTools];
    self.jsContextHandler = [JSContextHandler new];
    [self.view addSubview:self.webView];
    NSData *data = [[NSString stringWithFormat:@"%@",[kUserDefaults valueForKey:userDefaults_userID]] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@uid=%@",self.address, base64String]];
    NSLog(@"url: %@",url);
    //测试
    //url = [NSURL URLWithString:@"http://192.168.3.3:8080/#/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.f];
    
    [self.webView loadRequest:request];
}
#pragma mark - delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // 当当前控制器是根控制器时，不可以侧滑返回，所以不能使其触发手势
    if(self.navigationController.childViewControllers.count == 1) {
        return NO;
    }
    if ([self.webView canGoBack]) {
        CGPoint point = [gestureRecognizer velocityInView:self.webView.scrollView];
        NSLog(@"%@",[NSValue valueWithCGPoint:point]);
        // 只有当横向滑动速度大于150时,并且纵向速度绝对值小于150时,才响应手势(可根据需要设置)
        if (point.x <= 150 || (point.y >= 150 || point.y <= -150)) {
            return NO;
        }
        [self.webView goBack];
        return NO;
    }
    return YES;
}
    
//MARK:UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //JS 用HandleJSRequest调原生代码
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"HandleJSRequest"] = _jsContextHandler;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"异常信息：%@",exception);
    };
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //调JS代码
    //    JSValue *shareCallBack = self.jsContext[@"testAlert"];
    //    [shareCallBack callWithArguments:@[@{@"key":@"fnsw",@"test":@"123"}]];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { // 获取点击页面加载的url
    NSString *url = request.URL.absoluteString;
    if ([url containsString:@"com.bookv3://shareByAppHHJFNSW"]) {
        // 通过获取当前点击页面加载的url与指定url进行比较，拦截页面请求，进行自己的逻辑处理
        // 进行移动端的逻辑处理
        NSString *params = [[url componentsSeparatedByString:@"com.bookv3://shareByAppHHJFNSW"] lastObject];
        NSArray *array = [params componentsSeparatedByString:@"HHJFNSW"];
        if (array.count < 3) {
            return NO;
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        
        NSString *shareURL = [array objectAtIndex:0];
        NSMutableString *shareURLStr = [NSMutableString string];
        if ([shareURL hasPrefix:@"http"]) {
            NSArray *shareURLArr = [shareURL componentsSeparatedByString:@"http"];
            [shareURLStr appendString:[NSString stringWithFormat:@"http:%@",[shareURLArr lastObject]]];
        }
        if ([shareURL hasPrefix:@"https"]) {
            NSArray *shareURLArr = [shareURL componentsSeparatedByString:@"https"];
            [shareURLStr appendString:[NSString stringWithFormat:@"https:%@",[shareURLArr lastObject]]];
        }
        [dict setSafeValue:shareURLStr forKey:@"url"];
        [dict setSafeValue:[self decodeFromPercentEscapeString:[array objectAtIndex:1]] forKey:@"title"];
        [dict setSafeValue:[self decodeFromPercentEscapeString:[array objectAtIndex:2]] forKey:@"description"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine)]];
            [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
                // 根据获取的platformType确定所选平台进行下一步操作
                NSMutableDictionary *shareInfo = [@{} mutableCopy];
                [shareInfo setSafeValue:[dict safeObjectForKey:@"thumImage"] forKey:shareThumbImgStr];
                [shareInfo setSafeValue:[dict safeObjectForKey:@"title"] forKey:shareTitle];
                [shareInfo setSafeValue:[dict safeObjectForKey:@"description"] forKey:shareDescr];
                [shareInfo setSafeValue:[dict safeObjectForKey:@"url"] forKey:shareWebPageURL];
                [ShareManager shareWebPageToPlatformType:platformType shareInfo:shareInfo success:^{
                    
                } failure:^(NSString * _Nonnull msg) {
                    
                }];
            }];
        });
    }
    return YES;
}

#pragma mark - gesture
- (void)back {
    [self.webView goBack];
}
#pragma mark - event response
- (void)refreshWebView {
    //_webView = nil;
    [_webView removeFromSuperview];
    [self.view addSubview:_webView];

    [self.webView reload];
    [self.webView.scrollView.mj_header endRefreshing];
}
#pragma mark - private
//MARK: URLScheme协议中含有中文转码
- (NSString *)decodeFromPercentEscapeString:(NSString *)input {
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)userTools {
    [[NetManager defaultNetManager] fetchNetDataWithURLStr:@"home/users/userTool" params:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [kUserDefaults setValue:[responseObject safeObjectForKey:@"show_data"] forKey:checkAppStatusParam];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
#pragma mark - getter
- (UIWebView *)webView {
    if (!_webView) {
        //获取状态栏的rect
//        CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
//        if (@available(iOS 11.0, *)) {
//            _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -statusRect.size.height, self.view.bounds.size.width, self.view.bounds.size.height+self.view.safeAreaInsets.bottom)];
//        } else {
//            // Fallback on earlier versions
//        }
        if (@available(iOS 11.0, *)) {
            _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height+self.view.safeAreaInsets.bottom)];
        } else {
            // Fallback on earlier versions
            _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height+40)];
        }
        _webView.backgroundColor = [UIColor colorWithRed:241./255. green:241./255. blue:241./255. alpha:1];
        _webView.opaque = NO;
        _webView.delegate = self;
        _webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWebView)];
        for (UIView *subView in _webView.scrollView.mj_header.subviews) {
            subView.hidden = YES;
        }
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(back)] ;
        panGesture.delegate = self;
        [_webView addGestureRecognizer:panGesture];
    }
    return _webView;
}
@end
