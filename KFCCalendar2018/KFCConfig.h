//
//  KFCConfig.h
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "UIView+Frame.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "UIColor+Hex.h"
#import "UIImage+Resize.h"
#import "KFCProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


#ifndef KFCConfig_h
#define KFCConfig_h

#define WS(weakSelf)    __weak __typeof(&*self)weakSelf = self;

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define KFC_COLOR_WITH_RGB(r, g, b)     [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
#define KFC_COLOR_HEXCOLOR(s)           [UIColor colorWithHexString:s]

#define KFC_COLOR_LIGHT_YELLOW KFC_COLOR_HEXCOLOR(@"F5F0E9")

#define KFC_CONST_QRVIEW_TRANSPARENT_AREA_WIDTH  SCREEN_WIDTH - 38 * 2

#define KFC_NOTIFICATION_CENTER         [NSNotificationCenter defaultCenter]
#define KFC_USER_DEFAULTS               [NSUserDefaults standardUserDefaults]

//**** NOTIFICATIONS
// AR 识别成功
#define KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED                       @"KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED"
// 识别成功之后 刷新数据
#define KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED_RELOAD_DATA           @"KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED_RELOAD_DATA"
//  有editimageview 状态为 active的时候  发个通知, 隐藏返回和保存按钮
#define KFC_NOTIFICATION_NAME_EDIT_IMAGE_VIEW_ACTIVE                @"KFC_NOTIFICATION_NAME_EDIT_IMAGEVIEW_ACTIVE"

//**** USER DEFAULT
// 第一次启动
#define KFC_USER_DEFAULT_IS_FIRST_LAUNCH        @"KFC_USER_DEFAULT_IS_FIRST_LAUNCH"
#define KFC_USER_DEFAULT_APP_VERSION            @"KFC_USER_DEFAULT_APP_VERSION"

// 已经下载过的图片
#define KFC_USER_DEFAULT_DOWN_LOADED_IAMGES     @"KFC_USER_DEFAULT_DOWN_LOADED_IAMGES"
// 已经使用过的图片
#define KFC_USER_DEFAULT_USED_IMAGES            @"KFC_USER_DEFAULT_USED_IMAGES"

#define KFC_USER_DEFAULT_UDID                   @"KFC_USER_DEFAULT_UDID"


//**** URL
/*******  page ********/
#define KFC_URL_CALENDAR_TASK_LIST          @"https://www.youbohudong.com/biz/vip/kfc/calendar-2018/tasks"

/*******  api  *********/
#define KFC_URL_CALENDAR_NEW_STAMPS         @"https://www.youbohudong.com/api/biz/vip/kfc/calendar-2018/stamps"
#define KFC_URL_CALENDAR_COMPLETE_TASKS     @"https://www.youbohudong.com/api/biz/vip/kfc/calendar-2018/tasks"
//https://www.youbohudong.com/biz/vip/kfc/calendar-2018/api/tasks/<uuid>/<taskKey>   用户完成taskKey后更新服务器记录

//**** ACCOUNT
#define KFC_WX_APP_ID                   @"wx9b7b3c02f132a518"
#define KFC_EASY_AR_KEY                 @"amxBNPSXKbRBragBOjnJ0rV5tjSBwQZFk3SqTyd8qlTOv54A8CFjO4fP8RaVD9NDDKcvzXc4aPWHFj7cW5gtViFP1Q4j5nD23zodBz30agY29ai2ar7VQPcW7n41yxP8zv5ZlNhWy1vY4xujQpW8U34E9ZLyKT3byHamzdqWwUD1jnoGS82pRYqGQXiiQGn2pfpwC5BO"

#endif /* KFCConfig_h */
