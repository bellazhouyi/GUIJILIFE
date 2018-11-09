//
//  NetManager.h
//  FNMenu
//
//  Created by 航汇聚科技 on 2018/9/5.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetManager : NSObject

+ (instancetype)defaultNetManager;


- (void)fetchNetDataWithURLStr:(NSString *)urlStr
                        params:(NSDictionary *)params
                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
- (id)synGetRequestByUrlStr:(NSString *)urlStr;
- (void)uploadPhoto:(UIImage *)image
             urlStr:(NSString *)urlStr
         parameters:(NSDictionary *)params
constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
           progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
            success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (NSString *)app_version;
- (NSString *)phoneType;
@end

NS_ASSUME_NONNULL_END
