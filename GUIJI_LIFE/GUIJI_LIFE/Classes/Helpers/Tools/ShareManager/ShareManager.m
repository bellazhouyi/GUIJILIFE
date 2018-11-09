//
//  ShareManager.m
//  FNMenu
//
//  Created by 航汇聚科技 on 2018/9/27.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import "ShareManager.h"
#import "NSDictionary+Safety.h"
@implementation ShareManager

+ (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
                         shareInfo:(NSDictionary *)shareInfo
                           success:(void(^)(void))success
                           failure:(void(^)(NSString *msg))failure {
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    NSString *thumbImgStr = [shareInfo safeObjectForKey:shareThumbImgStr];
    NSString *thumbURL = [thumbImgStr stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:[shareInfo safeObjectForKey:shareTitle] descr:[shareInfo safeObjectForKey:shareDescr] thumImage:thumbURL];
    //设置网页地址
    shareObject.webpageUrl = [shareInfo safeObjectForKey:shareWebPageURL];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}

@end
