//
//  KFCPasterModel.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFCPasterModel : NSObject

//  id
@property(nonatomic,assign) int id;


@property(nonatomic,assign) int isNew;

// 当前是否可用
@property(nonatomic,assign) int isAvailable;

@property(nonatomic,copy) NSString *name;

// 不可用的时候， 按住显示出来的提示框
@property(nonatomic,copy) NSString *note;

@property(nonatomic,strong) NSArray *stamps;

//@property(nonatomic,copy) NSString *sunNail;


@end



/*
(
 {
     isAvailable = 0;
     isNew = 1;
     name = "\U6bd4\U5229\U65f6\U751c\U7b52";
     note = "12\U670818\U65e5\U8d34\U7eb8\U5f00\U542f\Uff0c\U626b\U626b\U82b1\U7b52\U66f4\U53ef\U83b7\U5f97\U9650\U91cf\U7248\U8d34\U7eb8\Uff01";
     stamps =         (
                       {
                           image = "https://static.youbohudong.com/uploaded/2017/11/14/6870fb7c8eb2a517eb140013bd544fff.png";
                           note = "\U5b8c\U6210\U4efb\U52a1\U89e3\U9501\U5b8c\U6210\U4efb\U52a1\U89e3\U9501\U5b8c\U6210\U4efb\U52a1\U89e3\U9501\U5b8c\U6210\U4efb\U52a1\U89e3\U9501\U5b8c\U6210\U4efb\U52a1\U89e3\U9501";
                           taskKey = "belgium_ice_cream_20181218";
                           thumb = "https://static.youbohudong.com/uploaded/2017/11/14/6870fb7c8eb2a517eb140013bd544fff.png?x-oss-process=image/resize,limit_0,w_180";
                       },
                       {
                           image = "https://static.youbohudong.com/uploaded/2017/11/14/7ce16bfabf54b74bc542fb3b630d203c.png";
                           taskKey = "belgium_ice_cream_20181218";
                           thumb = "https://static.youbohudong.com/uploaded/2017/11/14/7ce16bfabf54b74bc542fb3b630d203c.png?x-oss-process=image/resize,limit_0,w_180";
                       },
                       {
                           image = "https://static.youbohudong.com/uploaded/2017/11/14/75cb81bbb24cfe18efac7fc5dd0d74ef.png";
                           taskKey = "belgium_ice_cream_20181218";
                           thumb = "https://static.youbohudong.com/uploaded/2017/11/14/75cb81bbb24cfe18efac7fc5dd0d74ef.png?x-oss-process=image/resize,limit_0,w_180";
                       },
                       {
                           image = "https://static.youbohudong.com/uploaded/2017/11/14/b7c16896847ae5db10baba094381655a.png";
                           taskKey = "belgium_ice_cream_20181218";
                           thumb = "https://static.youbohudong.com/uploaded/2017/11/14/b7c16896847ae5db10baba094381655a.png?x-oss-process=image/resize,limit_0,w_180";
                       }
                       
                       );
 }
 )

 
 */

