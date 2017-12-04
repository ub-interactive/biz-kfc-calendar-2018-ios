//
//  KFCStampGroupModel.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFCStampGroupModel : NSObject

//  id
@property(nonatomic, assign) int id;

@property(nonatomic, assign) int isNew;

// 当前是否可用
@property(nonatomic, assign) int isAvailable;

@property(nonatomic, copy) NSString *name;

// 不可用的时候， 按住显示出来的提示框
@property(nonatomic, copy) NSString *note;

@property(nonatomic, strong) NSArray *stamps;

@end
