//
//  HHJ_GetAllAppBundleID.m
//  汇聚书屋
//
//  Created by 航汇聚科技 on 2017/6/16.
//  Copyright © 2017年 航汇聚科技. All rights reserved.
//

#import "HHJ_GetAllAppBundleID.h"

#import <objc/runtime.h>

#import "NSString+Encrypt.h"

@interface HHJ_GetAllAppBundleID ()


@property(nonatomic, strong) NSMutableArray *tempAllInstalledBundleID;

@end

@implementation HHJ_GetAllAppBundleID

- (instancetype)init {
    if (self = [super init]) {
        [self touss];
    }
    return self;
}

- (void)touss
{
    if ([self ls_hhj_Application_hhj_Workspace_hhj_Function]) {
        Class lsawsc = objc_getClass([self ls_hhj_Application_hhj_Workspace_hhj_Function]);
        NSObject* workspace = [lsawsc performSelector:NSSelectorFromString([self default_hhj_Workspace_hhj_Function])];
        NSArray *Arr = [workspace performSelector:NSSelectorFromString([self all_hhj_Installed_hhj_Applications_hhj_Function])];
        for (NSString * tmp in Arr)
        {
            NSArray *resultArr = [self getParseBundleIdString:tmp];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
            [dict setValue:[resultArr firstObject] forKey:@"bundle_id"];
            [dict setValue:@"" forKey:@"install_time"]; //安装时间
            [self.tempAllInstalledBundleID addObject:dict];
        }
    }
}

- (NSArray *)getParseBundleIdString:(NSString *)description
{
    NSString * ret = @"";
    NSString * target = [description description];
    
    // iOS8.0 "LSApplicationProxy: com.apple.videos",
    // iOS8.1 "<LSApplicationProxy: 0x898787998> com.apple.videos",
    // iOS9.0 "<LSApplicationProxy: 0x145efbb0> com.apple.PhotosViewService <file:///Applications/PhotosViewService.app>"
    
    //用来装 bundle和
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if (target == nil)
    {
        return resultArray;
    }
    NSArray * arrObj = [target componentsSeparatedByString:@" "];
    switch ([arrObj count])
    {
        case 2: // [iOS7.0 ~ iOS8.1)
        case 3: // [iOS8.1 ~ iOS9.0)
        {
            ret = [arrObj lastObject];
            [resultArray addObject:ret];
        }
            break;
            
        case 4: // [iOS9 +)
        {
            ret = [arrObj objectAtIndex:2];
            [resultArray addObject:ret];
        }
            break;
        case 9:
        {
            ret = [arrObj objectAtIndex:2];
            [resultArray addObject:ret];
            [resultArray addObject:[arrObj objectAtIndex:3]];
            //[resultArray addObject:[arrObj objectAtIndex:7]];
        }
            break;
        default:
            break;
    }
    return resultArray;
}

#pragma mark - 打开应用程序,根据bundleID
- (void)openApplicationWithBundleID:(NSString *)bundleID {
    
    Class lsawsc = objc_getClass([self ls_hhj_Application_hhj_Workspace_hhj_Function]);
    NSObject* workspace = [lsawsc performSelector:NSSelectorFromString([self default_hhj_Workspace_hhj_Function])];
    // iOS6 没有defaultWorkspace
    if ([workspace respondsToSelector:NSSelectorFromString([self open_hhj_Application_hhj_With_hhj_Bundle_hhj_ID_hhj_Function])])
    {
        [workspace performSelector:NSSelectorFromString([self open_hhj_Application_hhj_With_hhj_Bundle_hhj_ID_hhj_Function]) withObject:bundleID];
    }
}


#pragma mark -
- (const char *)ls_hhj_Application_hhj_Workspace_hhj_Function {
    
    unsigned char str[] = {
        (XOR_KEY ^ 0x4C),
        (XOR_KEY ^ 0x53),
        (XOR_KEY ^ 0x41),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x63),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x74),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x6F),
        (XOR_KEY ^ 0x6E),
        (XOR_KEY ^ 0x57),
        (XOR_KEY ^ 0x6F),
        (XOR_KEY ^ 0x72),
        (XOR_KEY ^ 0x6B),
        (XOR_KEY ^ 0x73),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x63),
        (XOR_KEY ^ 0x65),
        (XOR_KEY ^ '\0')
    };
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"validate"] isEqual:@1]) {
         return [[NSString tokenNew_key:str] UTF8String];
    }else {
        //没有开启
        return NULL;
    }
}

- (NSString *)default_hhj_Workspace_hhj_Function {
    unsigned char str[] = {
        (XOR_KEY ^ 0x64),
        (XOR_KEY ^ 0x65),
        (XOR_KEY ^ 0x66),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x75),
        (XOR_KEY ^ 0x6c),
        (XOR_KEY ^ 0x74),
        (XOR_KEY ^ 0x57),
        (XOR_KEY ^ 0x6F),
        (XOR_KEY ^ 0x72),
        (XOR_KEY ^ 0x6B),
        (XOR_KEY ^ 0x73),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x63),
        (XOR_KEY ^ 0x65),
        (XOR_KEY ^ '\0')
    };
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"validate"] isEqual:@1]) {
        return [NSString tokenNew_key:str];
    }else {
        //没有开启
        return NULL;
    }
}

- (NSString *)all_hhj_Installed_hhj_Applications_hhj_Function {
    unsigned char str[] = {
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x49),
        (XOR_KEY ^ 0x6E),
        (XOR_KEY ^ 0x73),
        (XOR_KEY ^ 0x74),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x6c),
        (XOR_KEY ^ 0x65),
        (XOR_KEY ^ 0x64),
        (XOR_KEY ^ 0x41),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x63),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x74),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x6F),
        (XOR_KEY ^ 0x6E),
        (XOR_KEY ^ 0x73),
        (XOR_KEY ^ '\0')
    };
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"validate"] isEqual:@1]) {
        return [NSString tokenNew_key:str];
    }else {
        //没有开启
        return NULL;
    }
}
- (NSString *)open_hhj_Application_hhj_With_hhj_Bundle_hhj_ID_hhj_Function {
    unsigned char str[] = {
        (XOR_KEY ^ 0x6F),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x65),
        (XOR_KEY ^ 0x6E),
        (XOR_KEY ^ 0x41),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x70),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x63),
        (XOR_KEY ^ 0x61),
        (XOR_KEY ^ 0x74),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x6F),
        (XOR_KEY ^ 0x6E),
        (XOR_KEY ^ 0x57),
        (XOR_KEY ^ 0x69),
        (XOR_KEY ^ 0x74),
        (XOR_KEY ^ 0x68),
        (XOR_KEY ^ 0x42),
        (XOR_KEY ^ 0x75),
        (XOR_KEY ^ 0x6E),
        (XOR_KEY ^ 0x64),
        (XOR_KEY ^ 0x6C),
        (XOR_KEY ^ 0x65),
        (XOR_KEY ^ 0x49),
        (XOR_KEY ^ 0x44),
        (XOR_KEY ^ 0x3A),
        (XOR_KEY ^ '\0')
    };
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"validate"] isEqual:@1]) {
        return [NSString tokenNew_key:str];
    }else {
        //没有开启
        return NULL;
    }
}

#pragma mark - getter
- (NSMutableArray *)tempAllInstalledBundleID {
    if (!_tempAllInstalledBundleID) {
        _tempAllInstalledBundleID = [NSMutableArray arrayWithCapacity:10];
    }
    return _tempAllInstalledBundleID;
}


- (NSArray *)allInstalledBundleID {
    return [self.tempAllInstalledBundleID copy];
}

@end
