//
//  KFCEditImageView.h
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"

@interface KFCEditImageView : UIView <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIView *imgBgView;       // 底部半透明 背景
@property(nonatomic, strong) UIImageView *imageView;  //表情图片

@property(nonatomic, copy) NSString *imgName;  //图片name

@property(nonatomic, strong) UIButton *deleteButton;    //删除按钮
@property(nonatomic, strong) UIButton *scaleBtn;

@property(nonatomic, strong) CAShapeLayer *border;

@property(nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property(nonatomic, strong) UIRotationGestureRecognizer *rotateGesture;
@property(nonatomic, strong) UIPinchGestureRecognizer *pinch;

- (instancetype)initWithImage:(UIImage *)image;

/**
 设置当前选中的表情
 
 @param view 表情view
 */
+ (void)setActiveEmoticonView:(KFCEditImageView *)view;
//- (void)setScale:(CGFloat)scale;

@end
