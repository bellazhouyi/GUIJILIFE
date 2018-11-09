//
//  JSContextHandler.m
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/9.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import "JSContextHandler.h"
#import "NSDictionary+Safety.h"
#import "GravityInduction.h"
#import "TransferJsonManager.h"
#import "NetManager.h"
#import "CheckAppStatus.h"
#import "ZYDataCypher.h"
@implementation JSContextHandler

- (void)copy {
    NSLog(@"1234");
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message: %@",message.body);
    
    NSLog(@"message: %@",message.name);
}

//MARK: JSObjDelegate
- (BOOL)copy:(NSString *)copyStr {
    [[UIPasteboard generalPasteboard] setString:[copyStr stringByRemovingPercentEncoding]];
    return YES;
}
- (NSString *)paste {
    return [UIPasteboard generalPasteboard].string;
}
- (BOOL)startGravityInduction:(NSString *)taskID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GravityInduction defaultGravityInduction] startUpdateAccelerometerResult:^(NSInteger result) {
            NSLog(@"重力感应：%ld",(long)result);
        } taskID:taskID];
    });
    return YES;
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
            NSDictionary *dict = @{
                                   @"code":@"0",
                                   @"msg":@"请检查url或者uid或者detail_id是否正确！"
                                   };
            return [TransferJsonManager jsonStrFromDict:dict];
        }else {
            //上传打开应用的指令到服务器
            NSString *cypherParam = [[ZYDataCypher sharedDataCypher] writeData:[NSString stringWithFormat:@"uid=%@&detail_id=%@",uid, detail_id]];
            NSString *uploadToServerForOpenCommandUrl = [NSString stringWithFormat:@"%@?param=%@", url, cypherParam];
            id responseResult = [[NetManager defaultNetManager] synGetRequestByUrlStr:uploadToServerForOpenCommandUrl];
            return [TransferJsonManager jsonStrFromDict:responseResult];
            
        }
    }else {
        return [TransferJsonManager jsonStrFromDict:@{@"code":@"0",@"msg":@"应用未安装!"}];
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
    if ([[responseDict valueForKey:@"code"] isEqual:@1]) {
        NSDictionary *resultForActiveTask = [@{} mutableCopy];
        for (NSString *key in [responseDict allKeys]) {
            [resultForActiveTask setSafeValue:[responseDict valueForKey:key] forKey:key];
        }
        for (NSString *key in [[[GravityInduction defaultGravityInduction] gravityInductionData] allKeys]) {
            [resultForActiveTask setSafeValue:[[[GravityInduction defaultGravityInduction] gravityInductionData] valueForKey:key] forKey:key];
        }
        [resultForActiveTask setSafeValue:@"1" forKey:@"code"];
        [resultForActiveTask setSafeValue:@"ok" forKey:@"msg"];
        [resultForActiveTask setSafeValue:@"1" forKey:@"stopGravityInduction"];
        
        responseResult = [TransferJsonManager jsonStrFromDict:resultForActiveTask];
        
        NSLog(@"重力值：%@",responseResult);
        //停止重力感应
        dispatch_async(dispatch_get_main_queue(), ^{
            [[GravityInduction defaultGravityInduction] stopUpdate];
        });
        
    }else {
        //没有领取成功
        responseResult = [TransferJsonManager jsonStrFromDict:responseDict];
    }
    
    return responseResult;;
}
@end
