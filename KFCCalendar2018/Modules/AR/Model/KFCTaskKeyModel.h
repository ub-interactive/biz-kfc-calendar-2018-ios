//
//  KFCTaskKeyModel.h
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFCTaskKeyModel : NSObject

@property(nonatomic, copy) NSString *taskKey;

@property(nonatomic, assign) int completed;

@end


/*

[
 {
     "taskKey": "20181218_belgium_ice_cream",
     "completed": true
 }
 ]

*/
