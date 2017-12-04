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

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define KFC_COLOR_WITH_RGB(r,g,b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
#define KFC_COLOR_RANDOM_COLOR      KFC_COLOR_WITH_RGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define KFC_COLOR_HEXCOLOR(s)       [UIColor colorWithHexString:s]

#define KFC_COLOR_LIGHT_YELLOW KFC_COLOR_HEXCOLOR(@"F5F0E9")

#define KFC_CONST_QRVIEW_TRANSPARENT_AREA_WIDTH  SCREEN_WIDTH - 38 * 2


#define KFC_NOTIFICATION_CENTER         [NSNotificationCenter defaultCenter]
#define KFC_USER_DEFAULTS               [NSUserDefaults standardUserDefaults]

// 删除图片, editImageVIew 点击删除时发送的通知
//#define KFC_NOTIFICATION_CENTER_DELETE_ALL_EDIT_IAMGE_VIEW         @"KFC_NOTIFICATION_CENTER_DELETE_ALL_EDIT_IAMGE_VIEW"

// AR 识别成功
#define KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED              @"KFC_NOTIFICATION_NAME_AR_RECOGNISE_SUCCEED"
// 识别成功之后 刷新数据
#define KFC_NOTIFICATION_NAME_AR_RECOGNISE_SUCCEED_RELOAD_DATA              @"KFC_NOTIFICATION_NAME_AR_RECOGNISE_SUCCEED_RELOAD_DATA"

//  有editimageview 状态为 active的时候  发个通知, 隐藏返回和保存按钮
#define KFC_NOTIFICATION_NAME_EDIT_IMAGEVIEW_ACTIVE              @"KFC_NOTIFICATION_NAME_EDIT_IMAGEVIEW_ACTIVE"



// 第一次启动
#define KFC_USER_DEFAULT_IS_FIRST_LAUNCH        @"KFC_USER_DEFAULT_IS_FIRST_LAUNCH"
// 第一次照相
#define KFC_USER_DEFAULT_FIRST_TAKE_PHOTO       @"KFC_USER_DEFAULT_FIRST_TAKE_PHOTO"
// 第一次打开贴纸
#define KFC_USER_DEFAULT_FIRST_CHOOSE_PASTER    @"KFC_USER_DEFAULT_FIRST_CHOOSE_PASTER"
// 第一次分享
#define KFC_USER_DEFAULT_FIRST_SHARE            @"KFC_USER_DEFAULT_FIRST_SHARE"

#define KFC_USER_DEFAULT_APP_VERSION            @"KFC_USER_DEFAULT_APP_VERSION"

// 是否是 扫物体
#define KFC_USER_DEFAULT_IS_SCAN_OBJ            @"KFC_USER_DEFAULT_IS_SCAN_OBJ"


// 已经下载过的图片
#define KFC_USER_DEFAULT_DOWN_LOADED_IAMGES     @"KFC_USER_DEFAULT_DOWN_LOADED_IAMGES"
// 已经使用过的图片
#define KFC_USER_DEFAULT_USED_IMAGES            @"KFC_USER_DEFAULT_USED_IMAGES"



/*******  url  *********/

//之前的api地址 /biz/vip/kfc/calendar-2018 更改为 /biz/vip/kfc/calendar-2018/api/stamps

#define KFC_URL_CALENDAR_NEW_STAMPS    @"https://www.youbohudong.com/biz/vip/kfc/calendar-2018/api/stamps"


//https://www.youbohudong.com/biz/vip/kfc/calendar-2018/api/tasks/<uuid>   获取uuid的完成的任务列表
#define KFC_URL_CALENDAR_COMPLETE_TASKS     @"https://www.youbohudong.com/biz/vip/kfc/calendar-2018/api/tasks"
//https://www.youbohudong.com/biz/vip/kfc/calendar-2018/api/tasks/<uuid>/<taskKey>   用户完成taskKey后更新服务器记录



// ACCOUNTS

#define KFC_WX_APP_ID                   @"wx9b7b3c02f132a518"
#define KFC_WX_APP_SECRET               @"d993817946a64e27534fffb2465ba093"

#define KFC_WX_APP_BUNDLE_ID            @"com.youbohudong.kfc2018cal"

#define KFC_WX_APP_NAME                 @"K记大玩家"


// 菲林相机的
//#define KFC_WX_APP_ID                   @"wx5561f5d0c6ab5125"
//#define KFC_WX_APP_SECRET               @"05aeff61aaae1fde8f9cb92940015b25"

//#define KFC_WX_APP_BUNDLE_ID            @"mobi.reejoy.FilmCamera"

//#define KFC_WX_APP_NAME                 @"菲林相机"



#endif /* KFCConfig_h */
