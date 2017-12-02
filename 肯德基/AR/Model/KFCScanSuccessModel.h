//
//  KFCScanSuccessModel.h
//  肯德基
//
//  Created by 二哥 on 2017/11/18.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFCScanSuccessModel : NSObject

// 当前是否可用
//@property(nonatomic,assign) int isAvailable;

// 图片url
@property(nonatomic,copy) NSString *completionResource;

// 提示框中的文字
@property(nonatomic,copy) NSString *completionDescription;

// 跳转的链接
@property(nonatomic,copy) NSString *completionUrl;





@end


/*

{
    "completionResource": "https://static.youbohudong.com/uploaded/2017/11/14/6870fb7c8eb2a517eb140013bd544fff.png",
    "completionDescription": "您已经成功收集肯德基比利时巧克力冰激凌限量版贴纸，立即拍照炫耀一下！",
    "completionUrl": "http://www.apple.com"
}

*/
