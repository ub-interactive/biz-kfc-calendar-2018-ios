//
//  QRView.m
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/25.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import "QRView.h"
#import "QRUtil.h"
#import "KFCConfig.h"

#define CORNOR_LINE_LENGTH  90

#define CORNOR_LINE_WIDTH   3
#define CORNOR_LINE_MARGIN  (9 + CORNOR_LINE_WIDTH)

static NSTimeInterval kQrLineanimateDuration = 0.010;



@implementation QRView {

    UIImageView *qrLine;
    CGFloat qrLineY;
    JXQRButton *inputButton;
    
    UILabel *noticeMessageLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (!qrLine) {
        
        [self initQRLine];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kQrLineanimateDuration target:self selector:@selector(qrLineAnimation) userInfo:nil repeats:YES];
        [timer fire];
    }
    
}

- (void)initQRLine {
    
    
    CGRect screenBounds = [QRUtil screenBounds];
    qrLine  = [[UIImageView alloc] initWithFrame:CGRectMake(screenBounds.size.width / 2 - self.transparentArea.width / 2 + 10, screenBounds.size.height / 2 - self.transparentArea.height / 2 + 10, self.transparentArea.width - 20, 4)];
    qrLine.image = [UIImage imageNamed:@"qrLine"];
    qrLine.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:qrLine];
    qrLineY = qrLine.frame.origin.y;
    
//    inputButton = [[JXQRButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 60 , SCREEN_HEIGHT / 2 - self.transparentArea.height / 2 - 60, 120, 40)];
//    [inputButton setImage:[UIImage imageNamed:@"barcode"] forState:UIControlStateNormal];
//    inputButton.titleLabel.text = @"输入条码";
//    inputButton.titleLabel.font = JXC_FONT_SMALL;
//    [inputButton addTarget:self action:@selector(inputButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:inputButton];
    
    noticeMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 20)];
    noticeMessageLabel.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + self.transparentArea.height / 2 + 25);
    noticeMessageLabel.textColor = [UIColor whiteColor];
    noticeMessageLabel.textAlignment = NSTextAlignmentCenter;
    noticeMessageLabel.text = @"将标识图放入框内，开始扫描";
    noticeMessageLabel.font = [UIFont systemFontOfSize:14];
    noticeMessageLabel.alpha = 0.8f;
    [self addSubview:noticeMessageLabel];
    
    _missionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 190, 40)];
    _missionButton.center = CGPointMake(SCREEN_WIDTH / 2, CGRectGetMaxY(noticeMessageLabel.frame) + 15 + 20);
    [_missionButton setImage:[UIImage imageNamed:@"activityList"] forState:UIControlStateNormal];
    [_missionButton addTarget:self action:@selector(missionListButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_missionButton];
    
    
    self.scanImageButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 50 - 25, 100, 50, 50)];
    [self.scanImageButton setImage:[UIImage imageNamed:@"scanImg"] forState:UIControlStateNormal];
    [self.scanImageButton setImage:[UIImage imageNamed:@"scanImg_red"] forState:UIControlStateSelected];
    self.scanImageButton.selected = YES;
    self.scanImageButton.tag = 100;
    [self.scanImageButton addTarget:self action:@selector(scanImageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.scanImageButton];
    
    self.scanObjectButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 50 - 25, 100, 50, 50)];
    [self.scanObjectButton setImage:[UIImage imageNamed:@"scanObj_gray"] forState:UIControlStateNormal];
    [self.scanObjectButton setImage:[UIImage imageNamed:@"scanObj"] forState:UIControlStateSelected];
    self.scanObjectButton.tag = 200;
    [self.scanObjectButton addTarget:self action:@selector(scanObjectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.scanObjectButton];
}


- (void)qrLineAnimation {
    
    [UIView animateWithDuration:kQrLineanimateDuration / 2 animations:^{
        
        CGRect rect = qrLine.frame;
        rect.origin.y = qrLineY;
        qrLine.frame = rect;
        
    } completion:^(BOOL finished) {
        //  4 是qrline  的高度
        CGFloat maxBorder = self.frame.size.height / 2 + self.transparentArea.height / 2 - 4 - 10;
        if (qrLineY > maxBorder) {
            qrLineY = self.frame.size.height / 2 - self.transparentArea.height / 2 + 10;
        }
        qrLineY++;
    }];
}

- (void)drawRect:(CGRect)rect {
    
    //整个二维码扫描界面的颜色
    CGSize screenSize =[QRUtil screenBounds].size;
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    CGFloat transparentY = screenDrawRect.size.height / 2 - self.transparentArea.height / 2;
    
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(screenDrawRect.size.width / 2 - self.transparentArea.width / 2 + 10, transparentY +10, self.transparentArea.width - 20,self.transparentArea.height - 20);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 半透明蒙版
    [self addScreenFillRect:ctx rect:screenDrawRect];
    // 中间透明区域
    [self addCenterClearRect:ctx rect:clearDrawRect];
    // 白色线框
    [self addWhiteRect:ctx rect:clearDrawRect];
    // 四个角
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextSetRGBFillColor(ctx, 0.0  , 0.0 , 0.0, 0.3);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 222.0/255.0, 0.0, 0.0, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    //画四个边角
    CGContextSetLineWidth(ctx, CORNOR_LINE_WIDTH);
    CGContextSetRGBStrokeColor(ctx, 231.0 /255.0, 42.0/255.0, 48.0/255.0, 1);     // red
    
    //左上角
    CGPoint poinsTopLeftA[] = {CGPointMake(rect.origin.x - CORNOR_LINE_MARGIN + 0.7, rect.origin.y - CORNOR_LINE_MARGIN),CGPointMake(rect.origin.x - CORNOR_LINE_MARGIN + 0.7  , rect.origin.y + CORNOR_LINE_LENGTH)};
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x - CORNOR_LINE_MARGIN, rect.origin.y + 0.7 - CORNOR_LINE_MARGIN),CGPointMake(rect.origin.x + CORNOR_LINE_LENGTH, rect.origin.y+0.7 - CORNOR_LINE_MARGIN)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x + 0.7 - CORNOR_LINE_MARGIN, rect.origin.y + rect.size.height - CORNOR_LINE_LENGTH),
        CGPointMake(rect.origin.x +0.7 - CORNOR_LINE_MARGIN, rect.origin.y + rect.size.height + CORNOR_LINE_MARGIN)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x - CORNOR_LINE_MARGIN, rect.origin.y + rect.size.height - 0.7 + CORNOR_LINE_MARGIN) ,
        CGPointMake(rect.origin.x+0.7 + CORNOR_LINE_LENGTH, rect.origin.y + rect.size.height - 0.7 + CORNOR_LINE_MARGIN)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x + rect.size.width - CORNOR_LINE_LENGTH, rect.origin.y + 0.7 - CORNOR_LINE_MARGIN),
        CGPointMake(rect.origin.x + CORNOR_LINE_MARGIN + rect.size.width,rect.origin.y +0.7 - CORNOR_LINE_MARGIN)};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7 + CORNOR_LINE_MARGIN, rect.origin.y - CORNOR_LINE_MARGIN),
        CGPointMake(rect.origin.x + rect.size.width-0.7 + CORNOR_LINE_MARGIN,rect.origin.y + CORNOR_LINE_LENGTH +0.7)};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    // 右下角
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 + CORNOR_LINE_MARGIN, rect.origin.y+rect.size.height+ -CORNOR_LINE_LENGTH),
        CGPointMake(rect.origin.x-0.7 + rect.size.width + CORNOR_LINE_MARGIN , rect.origin.y +rect.size.height + CORNOR_LINE_MARGIN)};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - CORNOR_LINE_LENGTH , rect.origin.y + rect.size.height-0.7 + CORNOR_LINE_MARGIN),CGPointMake(rect.origin.x + rect.size.width + CORNOR_LINE_MARGIN, rect.origin.y + rect.size.height - 0.7 + CORNOR_LINE_MARGIN)};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

-(void)operateTorch:(UIButton *)btn {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (btn.selected) {
            
            [device setTorchMode: AVCaptureTorchModeOff];
        }else{
            [device setTorchMode: AVCaptureTorchModeOn];
        }
        [device unlockForConfiguration];
    }
    
    btn.selected = !btn.selected;
}


-(void)inputButtonClicked:(UIButton *)btn{

    noticeMessageLabel.hidden = YES;
    qrLine.hidden = YES;
    inputButton.hidden = YES;
    
    [self addSubview:self.inputTextField];
    [self addSubview:self.backQRButton];
    [self addSubview:self.sureButton];
    
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(animateTimerFire) userInfo:nil repeats:YES];
    [self.animateTimer fire];
    
    if (self.qrViewInputButtonClickedBlock) {
        self.qrViewInputButtonClickedBlock(YES);
    }
}

-(void)animateTimerFire{

    CGFloat interval = 5;
    
    CGFloat tempHeight = self.transparentArea.height;
    tempHeight -= interval;
    CGSize tempSize = CGSizeMake(250, tempHeight);
    self.transparentArea = tempSize;
    [self setNeedsDisplay];
    
    if (self.transparentArea.height <= 50 || self.transparentArea.height >= 250) {
        [self.inputTextField becomeFirstResponder];
        [self.animateTimer invalidate];
    }
}

-(void)animateTimerBackFire{
    
    CGFloat interval = 5;
    
    CGFloat tempHeight = self.transparentArea.height;
    tempHeight += interval;
    CGSize tempSize = CGSizeMake(250, tempHeight);
    self.transparentArea = tempSize;
    [self setNeedsDisplay];
    
    if (self.transparentArea.height <= 50 || self.transparentArea.height >= 250) {
        [self.animateTimer invalidate];
    }
}


/*
    扫海报
 */
-(void)scanImageButtonClicked:(UIButton *)sender{

    if (sender.isSelected) return;
    
    sender.selected = YES;
    self.scanObjectButton.selected = NO;
    
    [KFC_USER_DEFAULTS setObject:[NSNumber numberWithBool:NO] forKey:KFC_USER_DEFAULT_IS_SCAN_OBJ];
    [KFC_USER_DEFAULTS synchronize];
    
    if (self.qrViewScanButtonClickedBlock) {
        self.qrViewScanButtonClickedBlock(sender.tag);
    }
}



/*
    扫物体
 */
-(void)scanObjectButtonClicked:(UIButton *)sender{

    if (sender.isSelected) return;
    
    sender.selected = YES;
    self.scanImageButton.selected = NO;
    
    [KFC_USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KFC_USER_DEFAULT_IS_SCAN_OBJ];
    [KFC_USER_DEFAULTS synchronize];
    
    if (self.qrViewScanButtonClickedBlock) {
        self.qrViewScanButtonClickedBlock(sender.tag);
    }
    
}


/*
    任务列表 按钮点击
 */

-(void)missionListButtonClicked{
    
    if (self.qrViewSureButtonClickedBlock) {
        self.qrViewSureButtonClickedBlock(nil);
    }
    
}


-(void)backQRButtonClicked:(UIButton *)btn{

    noticeMessageLabel.hidden = NO;
    qrLine.hidden = NO;
    inputButton.hidden = NO;
    
    [btn removeFromSuperview];
    [self.inputTextField removeFromSuperview];
    [self.sureButton removeFromSuperview];
    
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(animateTimerBackFire) userInfo:nil repeats:YES];
    [self.animateTimer fire];
    
    if (self.qrViewInputButtonClickedBlock) {
        self.qrViewInputButtonClickedBlock(NO);
    }
}

-(void)sureButtonClicked{
    
    if (!self.inputTextField.text || [self.inputTextField.text isEqualToString:@""]) {
//        [KFCProgressHUD showError:@"请输入条码号"];
        return;
    }
    
    if (self.qrViewSureButtonClickedBlock) {
        self.qrViewSureButtonClickedBlock(self.inputTextField.text);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self sureButtonClicked];
    
    return YES;
}

-(UITextField *)inputTextField{
    
    if (_inputTextField == nil) {
        _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 125, 0, 250 , 50)];
        _inputTextField.y = SCREEN_HEIGHT / 2 - 125;
        _inputTextField.placeholder = @"请输入条码号";
        _inputTextField.backgroundColor = [UIColor whiteColor];
        _inputTextField.borderStyle = UITextBorderStyleNone;
        _inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputTextField.delegate = self;
        
    }
    return _inputTextField;
}

-(JXQRButton *)backQRButton{

    if (_backQRButton == nil) {
        _backQRButton = [[JXQRButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 140, CGRectGetMaxY(inputButton.frame) + 100, 120, 40)];
        [_backQRButton setImage:[UIImage imageNamed:@"scan_white"] forState:UIControlStateNormal];
        _backQRButton.titleLabel.text = @"切换扫码";
//        _backQRButton.titleLabel.font = JXC_FONT_SMALL;
        [_backQRButton addTarget:self action:@selector(backQRButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backQRButton;
}

-(JXQRButton *)sureButton{

    if (_sureButton == nil) {
        _sureButton = [[JXQRButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 20, CGRectGetMaxY(inputButton.frame) + 100, 120, 40)];
        _sureButton.titleLabel.text = @"确定";
//        _sureButton.titleLabel.font = JXC_FONT_DEFAULT;
        [_sureButton addTarget:self action:@selector(sureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

@end
