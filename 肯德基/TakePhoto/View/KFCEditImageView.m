//
//  KFCEditImageView.m
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//


#import "KFCEditImageView.h"
#import "KFCReTakeView.h"
#import "KFCConfig.h"


static const NSUInteger kDeleteBtnSize = 32;

@implementation KFCEditImageView{
    
    CGFloat _scale;    //当前缩放比例
    CGFloat _arg;       //当前旋转比例
    
    CGPoint _initialPoint; //表情的中心点
    CGFloat _initialScale;  //修改前的缩放比例
    CGFloat _initialArg;    //修改前旋转比例
}


+ (void)setActiveEmoticonView:(KFCEditImageView *)view{
    
    static KFCEditImageView *activeView = nil;
    if(view != activeView){
        [activeView setAvtive:NO]; //隐藏上一个表情的线和按钮
        activeView = view;
        
        //显示当前表情的线和按钮
        [activeView setAvtive:YES];
        //显示在最上层
        [activeView.superview bringSubviewToFront:activeView];
    }
    
    // 发个通知, 隐藏返回和保存按钮
    [KFC_NOTIFICATION_CENTER postNotificationName:KFC_NOTIFICATION_NAME_EDIT_IMAGEVIEW_ACTIVE object:view];
}


-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if (self) {
        // 要编辑的图片
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(16, 16, self.width - 32, self.height - 32);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _imageView.frame = self.bounds;
//        _imageView.center = self.center;
        
        self.imgBgView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.imgBgView.backgroundColor = [UIColor whiteColor];
        self.imgBgView.alpha = 0.3f;
        [self addSubview:self.imgBgView];
        
        [self addSubview:self.imageView];
        
        // 删除 按钮
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        self.deleteButton.frame = CGRectMake(0, 0, 32, 32);
//        self.deleteButton.center = _imageView.frame.origin;
        [self.deleteButton addTarget:self action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
        
        // 缩放/旋转按钮
        self.scaleBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 32, self.height - 32, kDeleteBtnSize, kDeleteBtnSize)];
        self.scaleBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.scaleBtn setImage:[UIImage imageNamed:@"scale"] forState:UIControlStateNormal];
        [self addSubview:self.scaleBtn];
        
        _scale = 1;
        _arg = 0;
        
        [self initGestures];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.multipleTouchEnabled = YES;
    }
    
    return self;
}
 

- (instancetype)initWithImage:(UIImage *)image{
//    self = [super initWithFrame:CGRectMake(0, 0, image.size.width+kDeleteBtnSize, image.size.height+kDeleteBtnSize)];
    
    if (self) {
        
    }
    
    return self;
}


- (void)initGestures{
    
    self.imageView.userInteractionEnabled = YES;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidPan:)];
    [self.imageView addGestureRecognizer:self.panGesture];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)]];
    
    [_scaleBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleBtnDidPan:)]];
    
    // 旋转手势
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidRotate:)];
    rotation.delegate = self;
    [self addGestureRecognizer:rotation];
    self.rotateGesture = rotation;
    
//     缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidPinch:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];\
    self.pinch = pinch;

}

// 

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}


//删除
- (void)clickDeleteBtn:(id)sender{
    
    KFCEditImageView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i = index+1; i < self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[KFCEditImageView class]]){
            nextTarget = (KFCEditImageView *)view;
            break;
        }
    }
    
    if(nextTarget == nil){
        for(NSInteger i = index - 1; i >= 0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[KFCEditImageView class]]){
                nextTarget = (KFCEditImageView*)view;
                break;
            }
        }
    }
    
    [[self class] setActiveEmoticonView:nextTarget];
    [self removeFromSuperview];

}

- (void)setAvtive:(BOOL)active{
    
    self.deleteButton.hidden = !active;
    self.scaleBtn.hidden = !active;
    self.imgBgView.hidden = !active;
    
    if (!active) {
        [self.border removeFromSuperlayer];
    }else{
        // 加个虚线的边框
        [self addBorderToLayer:self.imageView];
    }
}

- (void)setScale:(CGFloat)scale{
    
    _scale = scale;
    
    self.transform = CGAffineTransformIdentity;
    
    self.imageView.transform = CGAffineTransformMakeScale(_scale, _scale); //缩放
    self.imgBgView.transform = CGAffineTransformMakeScale(_scale, _scale); //缩放
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (self.imageView.width + 32)) / 2;
    rct.origin.y += (rct.size.height - (self.imageView.height + 32)) / 2;
    rct.size.width  = self.imageView.width + 32;
    rct.size.height = self.imageView.height + 32;
    self.frame = rct;
    
    self.imageView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    self.imgBgView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    
    self.transform = CGAffineTransformMakeRotation(_arg);  // 旋转
    
//    self.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(旋转的弧度值),X轴缩放值, Y轴缩放值); 

}

//  旋转手势
-(void)imageDidRotate:(UIRotationGestureRecognizer *)sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.pinch.enabled = NO;
        self.panGesture.enabled = NO;
    }
    
    sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
    
    [sender setRotation:0];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.pinch.enabled = YES;
        self.panGesture.enabled = YES;
    }
}

// 缩放手势
-(void)imageDidPinch:(UIPinchGestureRecognizer *)sender{

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.rotateGesture.enabled = NO;
        self.panGesture.enabled = NO;
    }
    
//    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, sender.scale, sender.scale);

//    [self setScale:MAX(sender.scale, 0.1)];
//
//    _scale = sender.scale;
    
//    sender.scale = 1;
    
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.rotateGesture.enabled = YES;
        self.panGesture.enabled = YES;
    }
}

-(void)imageDidTap:(UITapGestureRecognizer *)tap{
    
    [[self class] setActiveEmoticonView:self];
}

//拖动
- (void)imageDidPan:(UIPanGestureRecognizer*)sender{
    
    [[self class] setActiveEmoticonView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
}

//缩放
- (void)scaleBtnDidPan:(UIPanGestureRecognizer*)sender{
    
//    locationInView:获取到的是手指点击屏幕实时的坐标点；
//    translationInView：获取到的是手指移动后，在相对坐标中的偏移量
    
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1; //临时缩放值
    static CGFloat tmpA = 0; //临时旋转值
    if(sender.state == UIGestureRecognizerStateBegan){
        //表情view中的缩放按钮相对与表情view父视图中的位置
        _initialPoint = [self.superview convertPoint:_scaleBtn.center fromView:_scaleBtn.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        //缩放按钮中点与表情view中点的直线距离
        tmpR = sqrt(p.x * p.x + p.y * p.y);     //开根号
        //缩放按钮中点与表情view中点连线的斜率角度
        tmpA = atan2(p.y, p.x);                 //反正切函数
        
        _initialArg = _arg;
        _initialScale = _scale;
        
    }
    
    // 全是 imageView 的
//    CGFloat oldWidth = _initialPoint.x - (self.x + 16);
//    CGFloat oldHeight = _initialPoint.y - (self.y + 16);
    
//    CGFloat newWidth = _initialPoint.x + p.x - (self.x + 16);
//    CGFloat newHeight = _initialPoint.y + p.y - (self.y + 16);
    
//    CGFloat scaleX = newWidth / oldWidth;
//    CGFloat scaleY = newHeight / oldHeight;
    
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x * p.x + p.y * p.y); //拖动后的距离
    CGFloat arg = atan2(p.y, p.x);    // 拖动后的旋转角度
    //旋转角度
    _arg   = _initialArg + arg - tmpA; //原始角度+拖动后的角度 - 拖动前的角度
    //放大缩小的值
    [self setScale:MAX(_initialScale * R / tmpR, 0.1)];
    
    [self.border removeFromSuperlayer];
    [self addBorderToLayer:self.imageView];
}



/**
  加个虚线的边框

 */
- (void)addBorderToLayer:(UIView *)view{
    
    CAShapeLayer *border = [CAShapeLayer layer];
    //  线条颜色
    border.strokeColor = [UIColor whiteColor].CGColor;
    border.fillColor = nil;
    border.path = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    border.frame = view.bounds;
    // 不要设太大 不然看不出效果
//    border.lineWidth = 1;
    border.lineWidth = 1 / _scale;      // 根据缩放比例 实时计算
//    border.lineCap = @"square";
    
    //  第一个是 线条长度   第二个是间距    nil时为实线
    NSNumber *num = [NSNumber numberWithDouble:3 / _scale];
    border.lineDashPattern = @[num, num];
    
    [view.layer addSublayer:border];
    
    self.border = border;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    
    
    
}


@end
