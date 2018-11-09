//
//  ShareManager.h
//  FNMenu
//
//  Created by 航汇聚科技 on 2018/9/27.
//  Copyright © 2018年 Yi Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UShareUI/UShareUI.h>
NS_ASSUME_NONNULL_BEGIN
static NSString *shareThumbImgStr = @"shareThumbImgStr";
static NSString *shareTitle = @"shareTitle";
static NSString *shareDescr = @"shareDescr";
static NSString *shareWebPageURL = @"shareWebPageURL";
@interface ShareManager : NSObject

+ (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
                         shareInfo:(NSDictionary *)shareInfo
                           success:(void(^)(void))success
                           failure:(void(^)(NSString *msg))failure;

@end

NS_ASSUME_NONNULL_END
