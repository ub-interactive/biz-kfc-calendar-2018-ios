//
//  UIView+Frame.h
//  WWImageEdit
//
//  Created by 邬维 on 2016/12/29.
//  Copyright © 2016年 kook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)


@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;


@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@end
