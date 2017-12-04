//
//  AppDelegate.h
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(strong, nonatomic) NSArray *taskKeyArray;

@end

