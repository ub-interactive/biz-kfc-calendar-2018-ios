//
//  KFCEditImageView.m
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//


#import "KFCEditImageView.h"
#import "KFCConfig.h"


static const NSUInteger kDeleteBtnSize = 32;

@implementation KFCEditImageView {

    CGFloat scale;    //当前缩放比例
    CGFloat rotate;       //当前旋转比例

    CGPoint initialOrigin; //表情的中心点
    CGFloat initialScale;  //修改前的缩放比例
    CGFloat initialRotate;    //修改前旋转比例

    CGFloat lastRotate;    //修改前旋转比例
}


+ (void)setActiveStampView:(KFCEditImageView *)view {

    static KFCEditImageView *activeView = nil;
    if (view != activeView) {
        [activeView setActive:NO]; //隐藏上一个表情的线和按钮
        activeView = view;

        //显示当前表情的线和按钮
        [activeView setActive:YES];
        //显示在最上层
        [activeView.superview bringSubviewToFront:activeView];
    }

    // 发个通知, 隐藏返回和保存按钮
    [KFC_NOTIFICATION_CENTER postNotificationName:KFC_NOTIFICATION_NAME_EDIT_IMAGE_VIEW_ACTIVE object:view];
}


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (self) {
        // 要编辑的图片
        self.stampImageView = [[UIImageView alloc] init];
        self.stampImageView.frame = CGRectMake(16, 16, self.width - 32, self.height - 32);
        self.stampImageView.contentMode = UIViewContentModeScaleAspectFit;

        self.backgroundView = [[UIView alloc] initWithFrame:self.stampImageView.frame];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.alpha = 0.3f;

        [self addSubview:self.backgroundView];
        [self addSubview:self.stampImageView];

        // 删除 按钮
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [self.deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        self.deleteButton.frame = CGRectMake(0, 0, 32, 32);
        [self.deleteButton addTarget:self action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];

        // 缩放/旋转按钮
        self.dragButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 32, self.height - 32, kDeleteBtnSize, kDeleteBtnSize)];
        self.dragButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.dragButton setImage:[UIImage imageNamed:@"scale"] forState:UIControlStateNormal];
        [self addSubview:self.dragButton];

        scale = 1;
        rotate = 0;

        [self initGestures];

        self.backgroundColor = [UIColor clearColor];

        self.multipleTouchEnabled = YES;
    }

    return self;
}


- (void)initGestures {

    self.stampImageView.userInteractionEnabled = YES;

    [self.dragButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragButtonDidPan:)]];

    self.imagePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidPan:)];
    [self.stampImageView addGestureRecognizer:self.imagePanGestureRecognizer];
    [self.stampImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)]];

    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidRotate:)];
    rotationGestureRecognizer.delegate = self;
    [self addGestureRecognizer:rotationGestureRecognizer];
    self.rotationGestureRecognizer = rotationGestureRecognizer;

    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidPinch:)];
    pinchGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pinchGestureRecognizer];
    self.pinchGestureRecognizer = pinchGestureRecognizer;

}

// 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    return YES;
}


//删除
- (void)clickDeleteBtn:(id)sender {

    KFCEditImageView *nextTarget = nil;

    [[self class] setActiveStampView:nextTarget];
    [self removeFromSuperview];

}

- (void)setActive:(BOOL)active {

    self.deleteButton.hidden = !active;
    self.dragButton.hidden = !active;
    self.backgroundView.hidden = !active;

    if (!active) {
        [self.border removeFromSuperlayer];
    } else {
        // 加个虚线的边框
        [self refreshBorderFormView:self.stampImageView];
    }
}

- (void)setScale:(CGFloat)newScale {

    scale = newScale;

    self.transform = CGAffineTransformIdentity;

    self.stampImageView.transform = CGAffineTransformMakeScale(scale, scale); //缩放
    self.backgroundView.transform = CGAffineTransformMakeScale(scale, scale); //缩放

    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (self.stampImageView.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (self.stampImageView.height + 32)) / 2;
    rct.size.width = self.stampImageView.width + 32;
    rct.size.height = self.stampImageView.height + 32;
    self.frame = rct;

    self.stampImageView.center = CGPointMake(rct.size.width / 2, rct.size.height / 2);
    self.backgroundView.center = CGPointMake(rct.size.width / 2, rct.size.height / 2);

    self.transform = CGAffineTransformMakeRotation(rotate);  // 旋转
}

//  旋转手势
- (void)imageDidRotate:(UIRotationGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.pinchGestureRecognizer.enabled = NO;
        self.imagePanGestureRecognizer.enabled = NO;
    }

    self.transform = CGAffineTransformMakeRotation(sender.rotation + lastRotate);  // 旋转
    initialRotate = sender.rotation;

    if (sender.state == UIGestureRecognizerStateEnded) {
        self.pinchGestureRecognizer.enabled = YES;
        self.imagePanGestureRecognizer.enabled = YES;
        lastRotate += sender.rotation;
    }
}

// 缩放手势
- (void)imageDidPinch:(UIPinchGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.rotationGestureRecognizer.enabled = NO;
        self.imagePanGestureRecognizer.enabled = NO;
    }

    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);

    sender.scale = 1;

    if (sender.state == UIGestureRecognizerStateEnded) {
        self.rotationGestureRecognizer.enabled = YES;
        self.imagePanGestureRecognizer.enabled = YES;
    }

    [self refreshBorderFormView:self.stampImageView];
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap {

    [[self class] setActiveStampView:self];
}

//拖动
- (void)imageDidPan:(UIPanGestureRecognizer *)sender {

    [[self class] setActiveStampView:self];

    CGPoint p = [sender translationInView:self.superview];

    if (sender.state == UIGestureRecognizerStateBegan) {
        initialOrigin = self.center;
    }
    self.center = CGPointMake(initialOrigin.x + p.x, initialOrigin.y + p.y);
}

//缩放
- (void)dragButtonDidPan:(UIPanGestureRecognizer *)sender {

//    locationInView:获取到的是手指点击屏幕实时的坐标点；
//    translationInView：获取到的是手指移动后，在相对坐标中的偏移量

    CGPoint p = [sender translationInView:self.superview];

    static CGFloat tmpR = 1; //临时缩放值
    static CGFloat tmpA = 0; //临时旋转值
    if (sender.state == UIGestureRecognizerStateBegan) {
        //表情view中的缩放按钮相对与表情view父视图中的位置
        initialOrigin = [self.superview convertPoint:_dragButton.center fromView:_dragButton.superview];

        CGPoint p = CGPointMake(initialOrigin.x - self.center.x, initialOrigin.y - self.center.y);
        //缩放按钮中点与表情view中点的直线距离
        tmpR = (CGFloat) sqrt(p.x * p.x + p.y * p.y);     //开根号
        //缩放按钮中点与表情view中点连线的斜率角度
        tmpA = (CGFloat) atan2(p.y, p.x);                 //反正切函数

        initialRotate = rotate;
        initialScale = scale;

    }

    p = CGPointMake(initialOrigin.x + p.x - self.center.x, initialOrigin.y + p.y - self.center.y);
    CGFloat R = (CGFloat) sqrt(p.x * p.x + p.y * p.y); //拖动后的距离
    CGFloat arg = (CGFloat) atan2(p.y, p.x);    // 拖动后的旋转角度
    //旋转角度
    rotate = initialRotate + arg - tmpA + lastRotate; //原始角度+拖动后的角度 - 拖动前的角度
    //放大缩小的值
    [self setScale:(CGFloat) MAX(initialScale * R / tmpR, 0.1)];

    [self refreshBorderFormView:self.stampImageView];
}


/**
  加个虚线的边框

 */
- (void)refreshBorderFormView:(UIView *)view {
    [self.border removeFromSuperlayer];

    CAShapeLayer *border = [CAShapeLayer layer];
    //  线条颜色
    border.strokeColor = [UIColor whiteColor].CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    border.frame = view.bounds;
    // 不要设太大 不然看不出效果

    border.lineWidth = 1;
    border.lineDashPattern = @[@2, @3];

    [view.layer addSublayer:border];

    self.border = border;
}


@end
