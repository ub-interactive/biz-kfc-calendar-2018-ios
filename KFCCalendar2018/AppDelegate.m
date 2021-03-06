//
//  AppDelegate.m
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "AppDelegate.h"
#import "KFCConfig.h"
#import <easyar/engine.oc.h>
#import "KFCTaskKeyModel.h"
#import "KFCScanViewController.h"


@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [FIRApp configure];
    
    //   微信
    [WXApi registerApp:KFC_WX_APP_ID];

    if (![easyar_Engine initialize:KFC_EASY_AR_KEY]) {
        NSLog(@"easyar_Engine Initialization Failed.");
    }

    [self getCompletedTasks];

    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(getCompletedTasks) name:KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED_RELOAD_DATA object:nil];

    return YES;
}

- (void)getCompletedTasks {

    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    [KFC_USER_DEFAULTS setObject:deviceId forKey:KFC_USER_DEFAULT_UDID];
    [KFC_USER_DEFAULTS synchronize];

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", KFC_URL_CALENDAR_COMPLETE_TASKS, deviceId];

    [[AFHTTPSessionManager manager] GET:urlStr parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        self.taskKeyArray = [KFCTaskKeyModel mj_objectArrayWithKeyValuesArray:responseObject];
    }                           failure:^(NSURLSessionTask *operation, NSError *error) {

    }];
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {

    if ([url.scheme isEqualToString:@"kc2018"]) {
        [self handleOpenKfcAPP:url];
    }

    return [WXApi handleOpenURL:url delegate:self];
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    //跳转到URL scheme中配置的地址
    return [WXApi handleOpenURL:url delegate:self];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.scheme isEqualToString:@"kc2018"]) {
        [self handleOpenKfcAPP:url];
    }
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)handleOpenKfcAPP:(NSURL *)url {

    if ([url.host isEqualToString:@"scan"]) {

        UINavigationController *nav = (UINavigationController *) self.window.rootViewController;
        for (UIViewController *vc in nav.viewControllers) {
            if ([vc isKindOfClass:[KFCScanViewController class]]) {
                [nav pushViewController:vc animated:YES];
                return;
            }
        }

        KFCScanViewController *viewController = [[KFCScanViewController alloc] init];
        [nav pushViewController:viewController animated:YES];
    } else if ([url.host isEqualToString:@"share"]) {

        NSMutableDictionary *dic = [self getURLParametersWithUrl:url];
        NSLog(@"NSMutableDictionary  ==  %@", dic);
        NSString *type = dic[@"type"];
        NSString *title = dic[@"title"];
        NSString *thumb = dic[@"thumb"];
        NSString *url = dic[@"url"];

        if (![WXApi isWXAppInstalled]) {
            return;
        }

        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]]]];
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        message.mediaObject = ext;

        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;

        if (type.intValue == 1) {
            req.scene = WXSceneSession;      // 好友
        } else {
            req.scene = WXSceneTimeline;      // 朋友圈
        }

        [WXApi sendReq:req];
    }
}

/*
    微信分享的callback
 */
#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {

    NSString *msg = @"分享成功! ";

    if (resp.errCode != WXSuccess) {
        msg = @"分享失败! ";
    }

    [KFCProgressHUD showWithString:msg inView:[UIApplication sharedApplication].keyWindow];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    (void) application;
    [easyar_Engine onPause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    (void) application;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    (void) application;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    (void) application;
    [easyar_Engine onResume];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    (void) application;
}


- (NSMutableDictionary *)getURLParametersWithUrl:(NSURL *)url {

    // 查找参数
    NSString *urlStr = url.absoluteString;

    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];

    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {

        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];

        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }

            id existValue = [params valueForKey:key];

            if (existValue != nil) {

                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];

                    [params setValue:items forKey:key];
                } else {

                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }

            } else {

                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数

        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];

        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }

        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }

        // 设置值
        [params setValue:value forKey:key];
    }

    return params;
}


@end

