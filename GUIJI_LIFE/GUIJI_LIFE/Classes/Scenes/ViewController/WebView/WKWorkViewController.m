//
//  WorkViewController.m
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/7.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import "WKWorkViewController.h"
@import WebKit;
#import <Masonry/Masonry.h>
#import <UShareUI/UShareUI.h>
#import <MJRefresh/MJRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSDictionary+Safety.h"
#import "ShareManager.h"
#import "TransferJsonManager.h"
#import "NetManager.h"
#import "NSDictionary+Safety.h"
#import "GravityInduction.h"
#import "TransferJsonManager.h"
#import "CheckAppStatus.h"
#import "ZYDataCypher.h"
#import "JSContextHandler.h"
@interface WKWorkViewController ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) JSContextHandler *jsContextHandler;
@end

@implementation WKWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _jsContextHandler = [JSContextHandler new];
    //1.先注册
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"shared"];
    [userContentController addScriptMessageHandler:self name:@"copyKey"];
    //[userContentController addScriptMessageHandler:self name:@"copyAndSearch"];
    [userContentController addScriptMessageHandler:self name:@"copyAndDownload"];
    [userContentController addScriptMessageHandler:self name:@"startGravityInduction"];
    [userContentController addScriptMessageHandler:self name:@"parse"];
    [userContentController addScriptMessageHandler:self name:@"active"];
    [userContentController addScriptMessageHandler:self name:@"openApp"];
    [userContentController addScriptMessageHandler:self name:@"openExternal"];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    
    if ([UIScreen mainScreen].bounds.size.height >= 812) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height+34) configuration:configuration];
    }else {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+40) configuration:configuration];
    }
    
    _webView.backgroundColor = [UIColor colorWithRed:241./255. green:241./255. blue:241./255. alpha:1];
    _webView.opaque = NO;
    _webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshWebView)];
    if (@available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    for (UIView *subView in _webView.scrollView.mj_header.subviews) {
        subView.hidden = YES;
    }
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(back)] ;
    panGesture.delegate = self;
    [_webView addGestureRecognizer:panGesture];
    
    [self userTools];
    [self.view addSubview:_webView];
    NSData *data = [[NSString stringWithFormat:@"%@",[kUserDefaults valueForKey:userDefaults_userID]] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@uid=%@",self.address, base64String]];
    NSLog(@"url: %@",url);
    //测试
    //url = [NSURL URLWithString:@"http://192.168.3.3:8080/#/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.f];
    
    [self.webView loadRequest:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWebView) name:@"open_success" object:nil];
}
#pragma - mark - 收到消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
   
    if ([message.name isEqualToString:@"openExternal"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:message.body]];
        });
    }
    if ([message.name isEqualToString:@"shared"]) {
        [self shared:message.body];
    }
    if ([message.name isEqualToString:@"copyKey"]) {
        [self copyKey:message.body];
        NSString *jsStr = [NSString stringWithFormat:@"copySuccess('ok')"];
        NSLog(@"jsStr: %@",jsStr);
        
        //发送消息
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error);
            }
        }];
    }
//    if ([message.name isEqualToString:@"copyAndSearch"]) {
//        [self copyKey:message.body];
//
//        NSString*str = [NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wa/search?mt=8&submit=edit&term=%@#software",[message.body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//           [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
//        });
//        NSLog(@"%@",str);
//
//        NSString *jsStr = [NSString stringWithFormat:@"copyAndSearchSuccess('ok')"];
//        NSLog(@"jsStr: %@",jsStr);
//        //发送消息
//        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"错误:%@", error);
//            }
//        }];
//    }
    if ([message.name isEqualToString:@"copyAndDownload"]) {
        [self copyKey:message.body];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:message.body]];
        });
        
        NSString *jsStr = [NSString stringWithFormat:@"copyAndDownloadSuccess('ok')"];
        NSLog(@"jsStr: %@",jsStr);
        //发送消息
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error);
            }
        }];
    }
    if ([message.name isEqualToString:@"startGravityInduction"]) {
        [self startGravityInduction:message.body];
        NSString *jsStr = [NSString stringWithFormat:@"startGravityInductionSuccess('ok')"];
        NSLog(@"jsStr: %@",jsStr);
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error);
            }
        }];
    }
    if ([message.name isEqualToString:@"parse"]) {
        [self paste];
        NSString *jsStr = [NSString stringWithFormat:@"parseSuccess('ok')"];
        NSLog(@"jsStr: %@",jsStr);
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error);
            }
        }];
    }
    if ([message.name isEqualToString:@"openApp"]) {
        NSString *result = [self openApp:message.body];
        
        
        NSString *jsStr = [NSString stringWithFormat:@"openAppSuccess('%@')",result];
        NSLog(@"jsStr: %@",jsStr);
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error);
            }
        }];
    }
    if ([message.name isEqualToString:@"active"]) {
        NSString *result = [self active:message.body];
        NSString *jsStr = [NSString stringWithFormat:@"activeSuccess('%@')", result];
        NSLog(@"jsStr: %@",jsStr);
        [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误:%@", error);
            }
        }];
    }
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

#pragma mark -
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%@",message);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *strRequest = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
    if ([strRequest hasPrefix:@"app://"]) {
        // 拦截点击链接
        // 不允许跳转 decisionHandler(WKNavigationActionPolicyCancel);
        
    }else {
        // 允许跳转 decisionHandler(WKNavigationActionPolicyAllow);
        
    }
        
}
#pragma mark - gesture
- (void)back {
    [self.webView goBack];
}
#pragma mark - event response
- (void)refreshWebView {
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
//MARK:
- (BOOL)copyKey:(NSString *)copyStr {
    [[UIPasteboard generalPasteboard] setString:[[NSString stringWithFormat:@"%@",copyStr] stringByRemovingPercentEncoding]];
    return YES;
}
- (NSString *)paste {
    return [UIPasteboard generalPasteboard].string;
}
- (void)shared:(NSString *)shareInfo { // 获取点击页面加载的url
    NSString *url = shareInfo;
    NSArray *array = [url componentsSeparatedByString:@"HHJFNSW"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSString *shareURL = [array objectAtIndex:0];
    [dict setSafeValue:shareURL forKey:@"url"];
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
- (void)startGravityInduction:(NSString *)taskID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GravityInduction defaultGravityInduction] startUpdateAccelerometerResult:^(NSInteger result) {
            NSLog(@"重力感应：%ld",(long)result);
        } taskID:taskID];
    });
}
static NSString * const SERVERPATH = @"https://new.feiniuapp.com";
- (id)openApp:(NSString *)params {
    NSDictionary *dict = [TransferJsonManager dictFromJsonStr:params];
    NSString *bundleID = [dict safeObjectForKey:@"bundleID"];
    NSString *uid = [dict safeObjectForKey:@"uid"];
    NSString *detail_id = [dict safeObjectForKey:@"detail_id"];
    NSString *url = [dict safeObjectForKey:@"url"];
    //NSString *type = [dict safeObjectForKey:@"type"];
    if ([CheckAppStatus checkOtherID:bundleID withDict:[kUserDefaults valueForKey:checkAppStatusParam]]) {
        if (!uid || !detail_id || !url) {
            return @"请检查url或者uid或者detail_id是否正确！";
        }else {
            //上传打开应用的指令到服务器
            NSString *cypherParam = [[ZYDataCypher sharedDataCypher] writeData:[NSString stringWithFormat:@"uid=%@&detail_id=%@",uid, detail_id]];
            NSString *uploadToServerForOpenCommandUrl = [NSString stringWithFormat:@"%@?param=%@", url, cypherParam];
            id responseResult = [[NetManager defaultNetManager] synGetRequestByUrlStr:uploadToServerForOpenCommandUrl];
            if ([responseResult safeObjectForKey:@"code"]) {
                return @"ok";
            }else {
                return [responseResult safeObjectForKey:@"msg"];
            }
        }
    }else {
        return @"应用未安装!";
    }
    return nil;
}
- (id)active:(NSString *)activeInfo {
    NSDictionary *dict = [TransferJsonManager dictFromJsonStr:activeInfo];
    
    NSMutableDictionary *mutableDict = [@{} mutableCopy];
    NSString *activeURL = [dict safeObjectForKey:@"url"];
    NSMutableString *activeParams = [@"" mutableCopy];
    int indexForKey = 0;
    for (NSString *key in dict.allKeys) {
        [mutableDict setSafeValue:[dict safeObjectForKey:key] forKey:key];
    }
    for (NSString *key in mutableDict.allKeys) {
        [activeParams appendFormat:@"%@=%@",key,[mutableDict safeObjectForKey:key]];
        if (indexForKey < dict.allKeys.count - 1) {
            [activeParams appendString:@"&"];
        }
        indexForKey ++;
    }
    
    NSString *cypherForwardParams = [[ZYDataCypher sharedDataCypher] writeData:activeParams];
    
    NSDictionary *responseDict = [[NetManager defaultNetManager] synGetRequestByUrlStr:[NSString stringWithFormat:@"%@?param=%@", activeURL, cypherForwardParams]];
    NSString *responseResult;
    if ([[responseDict safeObjectForKey:@"code"] isEqual:@1]) {
        
        NSMutableString *gravityParams = [NSMutableString stringWithFormat:@"uid=%@&tid=%@&",[dict safeObjectForKey:@"uid"],[dict safeObjectForKey:@"task_id"]];
        int index = 0;
        for (NSString *key in [[[GravityInduction defaultGravityInduction] gravityInductionData] allKeys]) {
            NSString *value = [[[GravityInduction defaultGravityInduction] gravityInductionData] safeObjectForKey:key];
            if (index < [[[GravityInduction defaultGravityInduction] gravityInductionData] allKeys].count - 1) {
                [gravityParams appendString:[NSString stringWithFormat:@"%@=%@&",key,value]];
            }else {
                [gravityParams appendString:[NSString stringWithFormat:@"%@=%@",key,value]];
            }
            index ++;
        }
        NSString *gravityUrlStr = [NSString stringWithFormat:@"https://new.feiniuapp.com/api/v4/task/save_zl?%@",gravityParams];
        NSLog(@"gravityUrlStr: %@",gravityUrlStr);
        NSDictionary *gravityResponseDict = [[NetManager defaultNetManager] synGetRequestByUrlStr:gravityUrlStr];
        
        if ([[gravityResponseDict safeObjectForKey:@"code"] isEqual:@1]) {
            //停止重力感应
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GravityInduction defaultGravityInduction] stopUpdate];
            });
            return @"ok";
        }else {
            return [gravityResponseDict safeObjectForKey:@"msg"];
        }
        
    }else {
        //没有领取成功
        return [responseDict safeObjectForKey:@"msg"];
    }
    
    return responseResult;;
}
@end
