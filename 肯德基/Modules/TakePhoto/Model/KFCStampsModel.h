//
//  KFCStampsModel.h
//  肯德基
//
//  Created by 二哥 on 2017/11/3.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFCStampsModel : NSObject


@property(nonatomic,copy) NSString *thumb;

@property(nonatomic,copy) NSString *image;

@property(nonatomic,copy) NSString *note;

@property(nonatomic,copy) NSString *taskKey;

@end

/*

{
    "thumb": "https://static.youbohudong.com/uploaded/2017/11/14/8d78651a326221b8f443fb17da6645b9.png?x-oss-process=image/resize,limit_0,w_180",
    "image": "https://static.youbohudong.com/uploaded/2017/11/14/8d78651a326221b8f443fb17da6645b9.png",
    "note": "扫扫甜筒即可获得该贴纸！",
    "taskKey": "bilishitiantong-01"
}

*/

/*

stamps =         (
                  {
                      image = "https://static.youbohudong.com/uploaded/2017/11/02/f1343b3747193ff0e11231d9f5851fb6.png";
                      thumb = "https://static.youbohudong.com/uploaded/2017/11/02/f1343b3747193ff0e11231d9f5851fb6.png?x-oss-process=image/resize,limit_0,w_180";
                  },
                  {
                      image = "https://static.youbohudong.com/uploaded/2017/09/23/eb76dc6a475a209c49755163b53e44cf.jpeg";
                      thumb = "https://static.youbohudong.com/uploaded/2017/09/23/eb76dc6a475a209c49755163b53e44cf.jpeg?x-oss-process=image/resize,limit_0,w_180";
                  }
                  );


*/
