//
//  NetManager.m
//  FNMenu
//
//  Created by 航汇聚科技 on 2018/9/5.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import "NetManager.h"
@import MapKit;
#import <AdSupport/AdSupport.h>
#import "NSDictionary+Safety.h"
#import "ZYDataCypher.h"
#import "TransferJsonManager.h"
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

const char * break_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};
#import <CommonCrypto/CommonCrypto.h>

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//获取设备类型
#include <sys/types.h>
#include <sys/sysctl.h>

//获取是否安装sim
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <SVProgressHUD/SVProgressHUD.h>
@interface NetManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation NetManager

+ (instancetype)defaultNetManager {
    static NetManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NetManager new];
        
        instance.sessionManager = [AFHTTPSessionManager manager];
        //超时设置
        instance.sessionManager.requestSerializer.timeoutInterval = 30;
        
        //解决https一直报 -999
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        //开启证书验证的,没这个  就不验证证书  https不验证证书是不通过的
        securityPolicy.allowInvalidCertificates = YES;
        [securityPolicy setValidatesDomainName:NO];
        instance.sessionManager.securityPolicy = securityPolicy;
        
        //申明返回的结果是json类型
        instance.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        //申明请求的数据是json类型
        instance.sessionManager.requestSerializer=[AFJSONRequestSerializer serializer];
        //如果报接受类型不一致请替换一致text/html或别的
        instance.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json", @"application/json",  @"text/javascript", @"text/html",@"text/plain", @"image/jpeg", @"image/png", nil];

    });
    return instance;
}

#if DEBUG
static NSString const *SERVERADDRESS = @"http://192.168.3.155:8080";
#else
static NSString const *SERVERADDRESS = @"https://caipu.hanghuiju.com";
#endif
- (void)fetchNetDataWithURLStr:(NSString *)urlStr
                        params:(NSDictionary *)params
                       success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    NSString *finalyURLStr;
    if ([urlStr hasPrefix:@"https://"] || [urlStr hasPrefix:@"http://"]) {
        finalyURLStr = urlStr;
    }else {
        finalyURLStr = [NSString stringWithFormat:@"%@/%@", SERVERADDRESS, urlStr];
    }
    if ([urlStr containsString:@"user/reg"] || [urlStr containsString:@"login"]) {
        NSMutableDictionary *dict = [@{} mutableCopy];
        for (NSString *key in params.allKeys) {
            [dict setSafeValue:[params safeObjectForKey:key] forKey:key];
        }
        [dict setSafeValue:[self idfa] forKey:@"idfa"];
        [dict setSafeValue:[self is_break_out] forKey:@"is_break_out"];
        [dict setSafeValue:[self os_version] forKey:@"os_version"];
        [dict setSafeValue:[self app_version] forKey:@"app_version"];
        [dict setSafeValue:[self idfv] forKey:@"idfv"];
        [dict setSafeValue:[self device_id] forKey:@"device_id"];
        [dict setSafeValue:[self uuid] forKey:@"uuid"];
        [dict setSafeValue:[self pad_or_phone] forKey:@"pad_or_phone"];
        [dict setSafeValue:[self sim] forKey:@"sim"];
        [dict setSafeValue:[self phoneType] forKey:@"device_type"];
        [dict setSafeValue:[self phoneType] forKey:@"device_model"];
        [dict setSafeValue:[self openudid] forKey:@"openudid"];
        [dict setSafeValue:[self isAuthLocation]==YES?@"1":@"0" forKey:@"authLocation"];
        params = dict;
        NSMutableString *getParams = [NSMutableString string];
        int index = 0;
        for (NSString *key in [dict allKeys]) {
            if (index < [dict allKeys].count) {
                [getParams appendFormat:@"%@=%@&",key,[dict valueForKey:key]];
            }else {
                [getParams appendFormat:@"%@=%@",key,[dict valueForKey:key]];
            }
            index ++;
        }
        NSString *cypherValue = [[ZYDataCypher sharedDataCypher] writeData:getParams];
        finalyURLStr = [NSString stringWithFormat:@"https://new.feiniuapp.com/%@?param=%@",urlStr,cypherValue];
        NSDictionary *regResponse = [self synGetRequestByUrlStr:finalyURLStr];
        NSURLSessionDataTask *task;
        success(task, regResponse==nil?@{}:regResponse);
    } else {
        //[SVProgressHUD show];
        [self.sessionManager POST:finalyURLStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //[SVProgressHUD dismiss];
            if ([[responseObject safeObjectForKey:@"code"] integerValue] == 1 || [[responseObject safeObjectForKey:@"error_code"] isEqual:@0]) {
                if ([urlStr containsString:@"user/reg"]) {
                    NSString *cypherResult = [[ZYDataCypher sharedDataCypher] readData:responseObject];
                    NSDictionary *regResponse = [TransferJsonManager dictFromJsonStr:cypherResult];
                    success(task, regResponse);
                } else {
                    success(task, responseObject);
                }
            }else {
                NSLog(@"!!!!!!!错误!!!");
                NSLog(@"finalyURLStr：%@",finalyURLStr);
                NSLog(@"params；%@",params);
                //[SVProgressHUD showErrorWithStatus:[responseObject safeObjectForKey:@"message"]];
            }
        }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //[SVProgressHUD dismiss];
            NSLog(@"失败!!!");
            NSLog(@"finalyURLStr：%@",finalyURLStr);
            NSLog(@"params；%@",params);
            //[SVProgressHUD setMinimumDismissTimeInterval:0.01];
            //[SVProgressHUD showErrorWithStatus:error.localizedDescription];
            failure(task, error);
        }];
    }
}

- (id)synGetRequestByUrlStr:(NSString *)urlStr {
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    // do something
    
    //1.创建URL
    NSURL *finalyURL = [[NSURL alloc]initWithString:urlStr];
    
    //2.创建请求对象--可变的可以设置请求方式
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:finalyURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    //设置请求方式--默认是GET
    [request setHTTPMethod:@"GET"];
    
    //3.创建响应对象
    NSURLResponse *response = nil;
    
    //4.创建错误对象
    NSError *error = nil;
    
    //5.链接，请求数据
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //得到的服务器端加密的字符串结果
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([urlStr containsString:@"task/save_zl"]) {
        return [TransferJsonManager dictFromJsonStr:result];
    }
    //默认解密之后的结果,code = 0
    NSString *cypherResult = [[ZYDataCypher sharedDataCypher] readData:result];
    
    return [TransferJsonManager dictFromJsonStr:cypherResult];
}

- (void)uploadPhoto:(UIImage *)image
             urlStr:(NSString *)urlStr
         parameters:(NSDictionary *)params
constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
           progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
            success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    NSString *finalyURLStr = [NSString stringWithFormat:@"%@/%@", SERVERADDRESS, urlStr];
    
    NSURLSessionDataTask *task = [self.sessionManager POST:finalyURLStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        //在IOS上，图片会被自动缩放到2的N次方大小。比如一张1024*1025的图片，占用的内存与一张1024*2048的图片是一致的。图片占用内存大小的计算的公式是；长*宽*4。这样一张512*512 占用的内存就是 512*512*4 = 1M。其他尺寸以此类推。（ps:IOS上支持的最大尺寸为2048*2048）。
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
      
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:@"avatar"
                                fileName:fileName
                                mimeType:@"image/png"];
        
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        //打印下上传进度
    } success:^(NSURLSessionDataTask *_Nonnull task,id _Nullable responseObject) {
        //上传成功
        success(task, responseObject);
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        //上传失败
        failure(task, error);
    }];
}

#pragma mark - public
- (NSString *)app_version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]==nil?@"nil_App_Version":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
#pragma mark - private
- (BOOL)isAuthLocation {
    BOOL result = NO;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            result = YES;
            break;
        default:
            break;
    }
    return result;
}
- (NSString *)idfa {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]==nil?@"nilIDFA":[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
- (NSString *)idfv {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString]==nil?@"idfv为空":[[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
- (NSString *)sim {
    //这里出现内存泄漏
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    if (!carrier.isoCountryCode) {
        // NSLog(@"No sim present Or No cellular coverage or phone is on airplane mode.");
        return @"0";
    }
    return @"1";
    
}
- (NSString *)os_version {
    return [[UIDevice currentDevice] systemVersion]==nil?@"nil_OS_Version":[[UIDevice currentDevice] systemVersion];
}
- (NSString *)device_id {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString]==nil?@"nil_DeviceID":[[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)uuid {
    return [[NSUUID UUID] UUIDString]==nil?@"nil_UUID":[[NSUUID UUID] UUIDString];
}
// 设备的UDID是唯一且永远不会改变
- (NSString *)udid {
    //这个是替换方案
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString]==nil?@"":[[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
//设备的OpenUDID是通过第一个带有OpenUDID SDK包的App生成，如果你完全删除全部带有OpenUDID SDK包的App（比如恢复系统等），那么OpenUDID会重新生成，而且和之前的值会不同，相当于新设备
- (NSString *)openudid {
    unsigned char result[16];
    const char *cStr = [[[NSProcessInfo processInfo] globallyUniqueString] UTF8String];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08llx",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
            arc4random() % 4294967295];
}
- (NSString *)pad_or_phone {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return @"iPad";
    }
    return @"iPhone";
}
- (NSString *)phoneType {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}
- (NSString *)is_break_out {
    if (![self isJailBreak] && ![self isJailBreakByFile]) {
        return @"0"; //不是越狱机
    }else{
        return @"1";
    }
}

- (BOOL)isJailBreak
{
    for (int i=0; i<ARRAY_SIZE(break_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:break_tool_pathes[i]]]) {
            return YES;
        }
    }
    return NO;
}
#define USER_APP_PATH                 @"/User/Applications/"
- (BOOL)isJailBreakByFile
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        //NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        return YES;
    }
    return NO;
}
@end
