//
//  JSContextHandler.h
//  GUIJI_LIFE
//
//  Created by 航汇聚科技 on 2018/11/9.
//  Copyright © 2018年 周屹. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;
#import "JSObjDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface JSContextHandler : NSObject<JSObjDelegate, WKScriptMessageHandler>


- (void)copy;
@end

NS_ASSUME_NONNULL_END
