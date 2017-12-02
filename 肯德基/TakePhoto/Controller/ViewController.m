//
//  ViewController.m
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//



#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "KFCConfig.h"
#import "KFCEditImageView.h"
#import "KFCReTakeView.h"
#import "KFCPasterView.h"
#import "KFCOneMoreView.h"
#import "WXApi.h"
#import "KFCPasterModel.h"
#import "KFCStampsModel.h"
#import "KFCPasterTableViewCell.h"
#import "KFCShareView.h"
#import "KFCScanViewController.h"
#import "KFCNewFeatureView.h"

@interface ViewController ()<KFCReTakeViewButtonClickDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,KFCPasterViewButtonClickDelegate,KFCOneMoreViewButtonClickDelegate,KFCShareViewButtonClickDelegate>


//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic,strong) KFCReTakeView *retakeView;

@property(nonatomic,strong) KFCPasterView *pasterView;

@property(nonatomic,strong) KFCOneMoreView *oneMoreView;

// 贴图前的照片
@property(nonatomic,strong) UIImage *image;
// 贴图后的照片
@property(nonatomic,strong) UIImage *editedImage;

@property(nonatomic,strong) UIImagePickerController *imagePickerController;

@property(nonatomic,strong) UIImageView *cameraImageView;

@property(nonatomic,strong) KFCEditImageView *editImageview;

@property(nonatomic,strong) UIView *temView;

@property(nonatomic,strong) NSMutableArray *usedImgArr;

@property(nonatomic,strong) KFCShareView *shareView;

// 对焦框view
@property(nonatomic,strong) UIView *preFocusView;

@property(nonatomic,strong) UIView *newfeatureView;

@property(nonatomic,strong) UIScrollView *newfeatureScrollView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 启动相机
    [self setupCamera];
    
    [self.view bringSubviewToFront:self.chageCameraButton];
    [self.view bringSubviewToFront:self.albumButton];
    [self.view bringSubviewToFront:self.takePhotoButton];
    [self.view bringSubviewToFront:self.addPicButton];
    [self.view bringSubviewToFront:self.scanButton];
    
    
    [self.view bringSubviewToFront:self.firstStepImageView];
    
    NSString *firstStep = [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_FIRST_TAKE_PHOTO];
    
    self.firstStepImageView.hidden = firstStep.intValue;
    
    if (!firstStep.intValue) {
        [KFC_USER_DEFAULTS setObject:@"1" forKey:KFC_USER_DEFAULT_FIRST_TAKE_PHOTO];
        [KFC_USER_DEFAULTS synchronize];
    }
    
    [self getPasterData];
    
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(editImageViewActive:) name:KFC_NOTIFICATION_NAME_EDIT_IMAGEVIEW_ACTIVE object:nil];
    
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(getPasterData) name:KFC_NOTIFICATION_NAME_AR_RECOGNISE_SUCCEED_RELOAD_DATA object:nil];
    
    // 判断是否显示 新特性页面
    
    NSString *savedVersion = [KFC_USER_DEFAULTS stringForKey:KFC_USER_DEFAULT_APP_VERSION];
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    NSComparisonResult result = [savedVersion compare:appVersion];
    //   是第一次使用app || 是第一次使用当前版本
    if (!savedVersion || result == NSOrderedAscending) {
    
        [KFC_USER_DEFAULTS setObject:appVersion forKey:KFC_USER_DEFAULT_APP_VERSION];

        [self showNewFeatureView];
    }

}


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    [self.session startRunning];
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [self.session stopRunning];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSArray *)setBaseData{
    
    KFCPasterModel *firstModel = [[KFCPasterModel alloc] init];
    firstModel.name = @"K记有态度";
    firstModel.isNew = 0;
    firstModel.isAvailable = 1;
    firstModel.stamps = [NSArray array];
    
    KFCPasterModel *secondModel = [[KFCPasterModel alloc] init];
    secondModel.name = @"2018日历";
    secondModel.isNew = 0;
    secondModel.isAvailable = 1;
    secondModel.stamps = [NSArray array];
    
    KFCPasterModel *lastModel = [[KFCPasterModel alloc] init];
    lastModel.name = @"敬请期待";
    lastModel.isNew = 0;
    lastModel.note = @"不定期推出新贴纸和限量版贴纸，请关注APP通知，收集贴纸，手慢则无哦！";
    lastModel.isAvailable = 0;
    
    NSMutableArray *baseArr = [[NSMutableArray alloc] init];
    // 前两个标签本来是本地的, 后改成从网络获取
//    [baseArr addObject:firstModel];
//    [baseArr addObject:secondModel];
    [baseArr addObject:lastModel];
    
    return [baseArr mutableCopy];
}

-(void)getPasterData{
    
    [self.data addObjectsFromArray:[self setBaseData]];
    
    [[AFHTTPSessionManager manager] GET:KFC_URL_CALENDAR_NEW_STAMPS parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        [self.data removeAllObjects];
        
        self.data = [KFCPasterModel mj_objectArrayWithKeyValuesArray:responseObject];
        
        [self.data addObjectsFromArray:[self setBaseData]];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
    }];
}

- (void)setupCamera{
    
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
//     拿到的图像的大小可以自行设定
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    //输入输出设备结合
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:self.previewLayer];
    
    //设备取景开始
    [self.session startRunning];
    
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯
        
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        
        [_device unlockForConfiguration];
    }

}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}

// 点击屏幕   开始聚焦

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    return;
    
    if ([self.view.subviews containsObject:self.retakeView]) return;
    
    //先进行判断是否支持控制对焦
    if (_device.isFocusPointOfInterestSupported && [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        
        NSError *error =nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [_device lockForConfiguration:&error];
        [_device setFocusMode:AVCaptureFocusModeAutoFocus];
        
        CGPoint locationP = [touches.anyObject locationInView:self.view];
        CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:locationP];
        
//        竖屏时候对焦点应是
//        (tap.x/self.view.frame.size.width, tap.y/self.view.frame.size.height)
        
        CGFloat rateX = locationP.x / self.view.width;
        CGFloat rateY = locationP.y / self.view.height;
        
        NSLog(@"locationP  x  ==  %.2f", locationP.x);
        NSLog(@"locationP  y  ==  %.2f", locationP.y);
        
        NSLog(@"rateX  x  ==  %.2f", rateX);
        NSLog(@"retaY  y  ==  %.2f", rateY);
        
        //        NSLog(@"self.focusView  ==  %@", self.focusView);
        
        NSLog(@"cameraPoint  x  ==  %.2f", cameraPoint.x);
        NSLog(@"cameraPoint  y  ==  %.2f", cameraPoint.y);
        
        [_device setFocusPointOfInterest:cameraPoint];
//        [_device setFocusPointOfInterest:CGPointMake(rateX, rateY)];
        
        //曝光模式
        if ([_device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [_device setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            NSLog(@"曝光模式修改失败");
        }
        
        //曝光点的位置
        if ([_device isExposurePointOfInterestSupported]) {
            [_device setExposurePointOfInterest:cameraPoint];
        }
        
        //  操作完成后，记得进行unlock。
        [_device unlockForConfiguration];
        
        
        if (self.preFocusView) [self.preFocusView removeFromSuperview];
        
        UIView *focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,160, 160)];
        focusView.center = locationP;
        focusView.backgroundColor = [UIColor clearColor];
        
        focusView.layer.borderColor = [UIColor colorWithRed:253.0 / 255.0 green:197.0 / 255.0 blue:52.0 / 255.0 alpha:1.0].CGColor;
        focusView.layer.borderWidth = 1;
        
        [self.view addSubview:focusView];
        
        [UIView animateWithDuration:0.3f animations:^{
            focusView.frame = CGRectMake(0, 0, 80, 80);
            focusView.center = locationP;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3f animations:^{
               focusView.alpha = 0.3f;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [focusView removeFromSuperview];
            });
        }];

        self.preFocusView = focusView;
    }

}



// 第二步图片是否显示
-(void)checkOutSecondStepStatus{

    NSString *secondStep = [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_FIRST_CHOOSE_PASTER];
    self.retakeView.secondStepImageView.hidden = YES;
//    self.retakeView.secondStepImageView.hidden = secondStep.intValue;
    
    if (!secondStep.intValue) {
        [KFC_USER_DEFAULTS setObject:@"1" forKey:KFC_USER_DEFAULT_FIRST_CHOOSE_PASTER];
        [KFC_USER_DEFAULTS synchronize];
    }
}



// 拍照
-(IBAction)takePhotoButtonClicked:(id)sender{

    self.firstStepImageView.hidden = YES;
    
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        NSLog(@"拍照失败!");
        return;
    }
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer == nil) return ;
        
        [self.session stopRunning];
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        self.image = [UIImage imageWithData:imageData];
        
        [UIView animateWithDuration:0 animations:^{
            [self addRetakeView:self.image];
        } completion:^(BOOL finished) {
           [self autoAddPasterView];
        }];
        
    }];
}


-(void)addRetakeView:(UIImage *)image{
    
    //  重新拍照 & 保存 的蒙版
    self.retakeView = [[NSBundle mainBundle] loadNibNamed:@"KFCReTakeView" owner:self options:nil].lastObject;
    self.retakeView.frame = self.view.bounds;
    
    NSLog(@"image  ==   %@", image);
    
    self.retakeView.delegate = self;
    [self.view addSubview:self.retakeView];
    
    
    // 根据图片比例 计算高度
    CGFloat ration = image.size.height / image.size.width;
    // 显示的高度
    CGFloat realHeight = SCREEN_WIDTH * ration;
    
    NSLog(@"realHeight  ==   %.2f", realHeight);
    
    self.cameraImageView = [[UIImageView alloc] initWithFrame:self.retakeView.bounds];
    self.cameraImageView.backgroundColor = [UIColor orangeColor];
    self.cameraImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.cameraImageView.userInteractionEnabled = YES;
//    self.cameraImageView.clipsToBounds = YES;
    
    self.cameraImageView.height = floorf(realHeight);       // 向下取整, 不然截图的时候 会有底部会有白边
    self.cameraImageView.center = self.retakeView.center;
    
    self.cameraImageView.image = self.image;
    [self.retakeView addSubview:self.cameraImageView];
    [self.retakeView sendSubviewToBack:self.cameraImageView];
    
    self.chageCameraButton.hidden = YES;
    self.albumButton.hidden = YES;
    self.takePhotoButton.hidden = YES;
    
    [self checkOutSecondStepStatus];
    
}



// 切换摄像头
-(IBAction)changeCameraButtonClicked:(id)sender{

    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        //给摄像头的切换添加翻转动画
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //拿到另外一个摄像头位置
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }
        //生成新的输入
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
//        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }

    
}


// 相册
-(IBAction)albumButtonClicked:(id)sender{
    
    self.firstStepImageView.hidden = YES;
    
    NSLog(@"相册");
    
    [self.session stopRunning];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
//    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    self.imagePickerController.allowsEditing = YES;
    
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    
    
}

// 扫一扫  AR
- (IBAction)scanButtonClicked:(UIButton *)sender {
    
    KFCScanViewController *scanViewController = [KFCScanViewController new];
    
    [self.navigationController pushViewController:scanViewController animated:YES];
    
}



#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
    self.image = image;
    [self addRetakeView:self.image];

    [self dismissViewControllerAnimated:picker completion:^{
        // 自动显示贴纸页面
        [self autoAddPasterView];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    [self dismissViewControllerAnimated:picker completion:^{
        [self.session startRunning];
    }];
}

#pragma mark - KFCReTakeViewButtonClickDelegate

-(void)reTakeViewButtonClicked:(NSInteger)buttonTag{
    
    [KFC_USER_DEFAULTS setObject:@"1" forKey:KFC_USER_DEFAULT_FIRST_CHOOSE_PASTER];
    [KFC_USER_DEFAULTS synchronize];
    
    if (buttonTag == 1) {       // 重拍 或  再拍一张
        
        self.chageCameraButton.hidden = NO;
        self.albumButton.hidden = NO;
        self.takePhotoButton.hidden = NO;
        
        [self.retakeView removeFromSuperview];
        [self.cameraImageView removeFromSuperview];
        [self.oneMoreView removeFromSuperview];
        
        [self.session startRunning];
        
    }else if(buttonTag == 2){      // 保存
        
        self.retakeView.retakeButton.hidden = YES;
        self.retakeView.saveButton.hidden = YES;
        self.retakeView.pasterButton.hidden = YES;
        
        self.cameraImageView.clipsToBounds = YES;
        
        [UIView animateWithDuration:0 animations:^{
            for (UIView *subView in self.cameraImageView.subviews) {
                if ([subView isKindOfClass:KFCEditImageView.class]) {
                    KFCEditImageView *imgView = (KFCEditImageView *)subView;
                    imgView.deleteButton.hidden = YES;
                    imgView.scaleBtn.hidden = YES;
                    imgView.imgBgView.hidden = YES;
                    [imgView.border removeFromSuperlayer];
                }
            }
        } completion:^(BOOL finished) {
           
            // 截个屏
            self.editedImage = [self captureImageFromView:self.cameraImageView];
            
            UIImageWriteToSavedPhotosAlbum(self.editedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }];
        
    }else{      // 贴纸
        
        self.retakeView.secondStepImageView.hidden = YES;
        
        [self autoAddPasterView];
    }
}

// 添加pasterview
-(void)autoAddPasterView{
    
    if (self.data.count && !self.pasterView.data.count) {
        self.pasterView.data = self.data;
    }
    [self.view addSubview:self.pasterView];
    [UIView animateWithDuration:0.3f animations:^{
        self.pasterView.x = 0;
    }];
}


// 图片和视频保存完毕后的回调

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSString *msg = @"保存图片成功! ";
    if(error != NULL){
        msg = @"保存图片失败  ";
    }
    [KFCProgressHUD showWithString:msg inView:self.view];
    
    if (error != NULL) return;
    
    // 保存完了,  显示 再拍一张 & 分享 按钮
    
    self.oneMoreView = [[NSBundle mainBundle] loadNibNamed:@"KFCOneMoreView" owner:self options:nil].lastObject;
    self.oneMoreView.frame = self.view.bounds;
    self.oneMoreView.delegate = self;
    
    NSString *firstShare = [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_FIRST_SHARE];
    self.oneMoreView.shareTipsImageView.hidden = firstShare.intValue;
    
    [self.view addSubview:self.oneMoreView];
    
    //  点保存的时候 再存储吧应该是  存储使用过的图片的名称或url
    NSMutableArray *usedImages = [[KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_USED_IMAGES] mutableCopy];
    if (!usedImages) {
        usedImages = [[NSMutableArray alloc] init];
    }
    [usedImages addObjectsFromArray:self.usedImgArr];
    
    [KFC_USER_DEFAULTS setObject:usedImages forKey:KFC_USER_DEFAULT_USED_IMAGES];
    [KFC_USER_DEFAULTS synchronize];
    
    [self.usedImgArr removeAllObjects];
}


/*
 *  截个屏
 */
-(UIImage *)captureImageFromView:(UIView *)view{
    
    CGRect frame = view.bounds;
//    UIGraphicsBeginImageContext(frame.size);      // 模糊的图
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);  // 原图  清晰
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



// 再拍一张
-(void)oneMoreViewButtonClicked:(UIButton *)button{
    
    [KFC_USER_DEFAULTS setObject:@"1" forKey:KFC_USER_DEFAULT_FIRST_SHARE];
    [KFC_USER_DEFAULTS synchronize];

    if (button.tag == 10) {     // 分享
        
        self.shareView = [[NSBundle mainBundle] loadNibNamed:@"KFCShareView" owner:self options:nil].lastObject;
        self.shareView.frame = [UIScreen mainScreen].bounds;
        self.shareView.y = 150;
        self.shareView.delegate = self;
        [self.view addSubview:self.shareView];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.shareView.y = 0;
        }];
        
    }else{     // 再拍一次
    
        [button removeFromSuperview];
        // 重拍
        [self reTakeViewButtonClicked:button.tag];
        
    }
}


-(void)shareViewButtonClicked:(UIButton *)button{
    
    
    if (button.tag == 0) {      // 取消
        
    }else if (button.tag == 1){     // 朋友圈
        
        [self shareToWechatWithType:WXSceneTimeline];
        
    }else if (button.tag == 2){     //  好友
        
        [self shareToWechatWithType:WXSceneSession];
        
    }else if (button.tag == 4){     // cover  button
        
        
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.shareView.y = 150;
    } completion:^(BOOL finished) {
        [self.shareView removeFromSuperview];
    }];
}


-(void)shareToWechatWithType:(int)scene{
    
    if(![WXApi isWXAppInstalled]) {
        [KFCProgressHUD showWithString:@"未检测到分享源" inView:self.view];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    [message setThumbImage:[self.editedImage resizedImageToFitInSize:CGSizeMake(150, 150) scaleIfSmaller:YES]];
//    message.title = @"111";
//    message.description = @"222";
    
    WXImageObject *imageObject = [WXImageObject object];
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"" ofType:@""];
//    imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
    
    imageObject.imageData = UIImageJPEGRepresentation(self.editedImage , 1 );
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    req.scene = scene;      // WXSceneSession
    
    [WXApi sendReq:req];
}


#pragma mark - KFCPasterViewButtonClickDelegate

// 长按图片  拖出来

-(void)pasterViewDidClickedWithImageName:(NSString *)imgName{
    
    
    // 不透明的图片  , 直接切的图
//    UIImage *tmpImg = [self shotWithView:cell.contentView];
//    UIImageView *temView = [[UIImageView alloc] initWithImage:tmpImg];
    
    // 透明的图片, 拿cell 中图片来用
//    UIView *temView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, 85)];
//    
//    UIView *imgBgView = [[UIView alloc] initWithFrame:temView.bounds];
//    imgBgView.backgroundColor = [UIColor whiteColor];
//    imgBgView.alpha = 0.3f;
//    [temView addSubview:imgBgView];
//    
//    UIImageView *temImageView = [[UIImageView alloc] initWithImage:cell.coverImageView.image];
//    temImageView.frame = temView.bounds;
//    [temView addSubview:temImageView];
    
    
    
//    if ([self.pasterView.subviews containsObject:self.temView]) {
//        [self.temView removeFromSuperview];
//    }
//    
//    [self.pasterView addSubview:temView];
//    self.temView = temView;
//    
//    //  其他的view 移除掉, 直接remove会有问题, 先hidden 吧 
//    for (UIView *subView in self.pasterView.subviews) {
//        
//        NSLog(@" subView  ==  %@", subView);
//        if (subView != temView) {
//            //                [subView removeFromSuperview];
//            subView.hidden = YES;
//        }
//    }
    
    //  跟随手指移动的截图
//    CGPoint newPoint = [sender locationInView:[UIApplication sharedApplication].keyWindow];
    
//    CGRect tempRect = temView.frame;
    
//    tempRect.origin.x = newPoint.x - temView.width;
//    tempRect.origin.y = newPoint.y - temView.height;
    
//    temView.center = newPoint;
    
//    if(sender.state == UIGestureRecognizerStateEnded){
    
//        CGPoint p = [sender locationInView:self.retakeView];
    
        CGFloat rate = (85 + 32) * 1.0 / (65 + 32) * 1.0;
    
        CGFloat imgW = [UIScreen mainScreen].bounds.size.width / 2;
    
//        if (type == imgNameTypeString) {
    
//            UIImage *img = [UIImage imageNamed:imgName];
//            
////            NSLog(@"bendi  image  ==  %@", img);
//            
//            // 图片的 高度和宽度
//            CGFloat imgWid = CGImageGetWidth(img.CGImage);
//            CGFloat imgHei = CGImageGetHeight(img.CGImage);
//            
//            CGFloat realHeight = imgW * (imgHei / imgWid);
//            
//            self.editImageview = [[KFCEditImageView alloc] initWithFrame:CGRectMake(0, 0, imgW, realHeight)];
//            
//            self.editImageview.center = self.cameraImageView.center;
//            self.editImageview.y = self.cameraImageView.height / 2 - self.editImageview.height / 2;
//            
//            self.editImageview.imageView.image = img;
            
//        }else if (type == imgNameTypeUrl) {
    
            UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgName];
            
//            NSLog(@"cachedImage  ==  %@", cachedImage);
            
            // 图片的 高度和宽度
            CGFloat imgWid = CGImageGetWidth(cachedImage.CGImage);
            CGFloat imgHei = CGImageGetHeight(cachedImage.CGImage);
            
            if (imgHei == 0.0) return;
            
            CGFloat realHeight = imgW * (imgHei / imgWid);
            
            self.editImageview = [[KFCEditImageView alloc] initWithFrame:CGRectMake(0, 0, imgW, realHeight)];
            self.editImageview.center = self.cameraImageView.center;
            self.editImageview.y = self.cameraImageView.height / 2 - self.editImageview.height / 2;
            self.editImageview.imageView.image = cachedImage;
            
//        }
        // 设置图片name, 发通知过来可删除
        self.editImageview.imgName = imgName;
        [self.cameraImageView addSubview:self.editImageview];
        [KFCEditImageView setActiveEmoticonView:self.editImageview];
    
    self.retakeView.saveButton.hidden = YES;
    self.retakeView.retakeButton.hidden = YES;
    
    // 给retakeview 加个点击手势, 点击的时候让 editImageView 的active 变成NO , 同时隐藏  返回&保存  按钮
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retakeViewTap:)];
    
    [self.retakeView addGestureRecognizer:tap];
    
        
//        [temView removeFromSuperview];
    
        // 拖动完成后 将paster view  移除
        [self.pasterView removeFromSuperview];
        self.pasterView.x = 145;
    
        // 点保存的时候 再存储吧应该是
//        [self.usedImgArr addObject:imgName];
//    }
    
}


-(void)retakeViewTap:(UITapGestureRecognizer *)tap{

    [KFCEditImageView setActiveEmoticonView:nil];
    
    self.retakeView.retakeButton.hidden = NO;
    self.retakeView.saveButton.hidden = NO;
}

-(void)editImageViewActive:(NSNotification *)noti{
    
    self.retakeView.retakeButton.hidden = (noti.object != nil);
    self.retakeView.saveButton.hidden = (noti.object != nil);
}


/**
 *  截取view中某个区域生成一张图片
 */
- (UIImage *)shotWithView:(UIView *)view inFrame:(CGRect)frame{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self shotWithView:view].CGImage, frame);
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    CGContextTranslateCTM(context, 0, rect.size.height);//下移
    CGContextScaleCTM(context, 1.0f, -1.0f);//上翻
    CGContextDrawImage(context, rect, imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    CGContextRelease(context);
    return image;
}


/**
 *  截取view生成一张图片
 */
- (UIImage *)shotWithView:(UIView *)view{
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//-(NSMutableArray *)usedImgArr{
//
//    if (!_usedImgArr) {
//        _usedImgArr = [NSMutableArray array];
//    }
//    return _usedImgArr;
//}


-(KFCPasterView *)pasterView{

    if (!_pasterView) {
        
        _pasterView = [[NSBundle mainBundle] loadNibNamed:@"KFCPasterView" owner:self options:nil].lastObject;
        _pasterView.frame = CGRectMake(145, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _pasterView.delegate = self;
        
    }
    return _pasterView;
}


-(NSMutableArray *)data{
    
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

/*****     新特性页面         **************/

-(void)showNewFeatureView{

    self.newfeatureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:self.newfeatureView];
    
    UIView *videoView = [[UIView alloc] initWithFrame:self.newfeatureView.bounds];
    [self.newfeatureView addSubview:videoView];
    
    //        NSString *fileName = [NSString stringWithFormat:@"newfeatur%zd", i];
    NSString *fileName = @"newfeature_0.MP4";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:filePath];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
    
    playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH + 40, SCREEN_HEIGHT);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [videoView.layer addSublayer:playerLayer];
    [videoPlayer play];
    
    videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[videoPlayer currentItem]];
    
    self.newfeatureScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.newfeatureScrollView.contentSize = CGSizeMake(4 * SCREEN_WIDTH, 0);
    self.newfeatureScrollView.pagingEnabled = YES;
    self.newfeatureScrollView.bounces = NO;
    self.newfeatureScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.newfeatureView addSubview:self.newfeatureScrollView];
    
    [self setScrollViewImages:self.newfeatureScrollView];
}

-(void)setScrollViewImages:(UIScrollView *)newfeatureScrollView{
    
    for (int i = 0 ; i < 4; i++) {
        
        KFCNewFeatureView *newFeaturePageView = [[NSBundle mainBundle] loadNibNamed:@"KFCNewFeatureView" owner:self options:nil].lastObject;
        newFeaturePageView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        newFeaturePageView.pageControl.currentPage = i;
        
        newFeaturePageView.iconImageView.hidden = (i != 0);
        
        newFeaturePageView.nextPageButton.tag = i;
        [newFeaturePageView.nextPageButton addTarget:self action:@selector(newfeatureNextPageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [newFeaturePageView.skipButton addTarget:self action:@selector(newfeatureSkipButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
         
            newFeaturePageView.titleLabel.text = @"欢迎来到 K记大玩家";
            newFeaturePageView.descLabel.text = @"带你在欢乐中走过2018，上校黑科技扫一扫赢优惠券。更有各种限量版活动贴纸等您来秀。";
        }else if (i == 1){

            newFeaturePageView.titleLabel.text = @"AR黑科技 扫扫有惊喜";
            newFeaturePageView.descLabel.text = @"带你在欢乐中走过2018，上校黑科技扫一扫赢优惠券。更有各种限量版活动贴纸等您来秀。带你在欢乐中走过2018，上校黑科技扫一扫赢优惠券。更有各种限量版活动贴纸等您来秀。";
        }else if (i == 2){
            
            newFeaturePageView.titleLabel.text = @"收集K记贴纸 秀翻朋友圈";
            newFeaturePageView.descLabel.text = @"带你在欢乐中走过2018，上校黑科技扫一扫赢优惠券。更有各种限量版活动贴纸等您来秀。";
        }else if (i == 3){
            
            newFeaturePageView.titleLabel.text = @"参加主题活动 赢惊喜礼物";
            newFeaturePageView.descLabel.text = @"带你在欢乐中走过2018，上校黑科技扫一扫赢优惠券。更有各种限量版活动贴纸等您来秀。";
        }
        
        if (i == 3) {       // 开始 按钮
            [newFeaturePageView.nextPageButton setImage:[UIImage imageNamed:@"newfeature_start"] forState:UIControlStateNormal];
        }
        
        [newfeatureScrollView addSubview:newFeaturePageView];
    }
    
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

/**
 *   下一页  or  开始
 */
-(void)newfeatureNextPageButtonClicked:(UIButton *)sender{
    
    [self.newfeatureScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * (sender.tag + 1), 0) animated:YES];
    
    if (sender.tag == 3) {      // 开始 按钮
        [self newfeatureSkipButtonClicked];
    }
    
}

/**
 *   跳过
 */

-(void)newfeatureSkipButtonClicked{
    
    [self.newfeatureView removeFromSuperview];
}


-(void)dealloc{

    [KFC_NOTIFICATION_CENTER removeObserver:self];
}

/*
 
 我们在有多个 UIView 层叠时，比如一个按钮被一个 UIView 遮盖时，想要在点击最上层的 UIView 时能触发按钮的相应事件
 
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(testHits){
        return nil;
    }
    
    if(!self.passthroughViews
       || (self.passthroughViews && self.passthroughViews.count == 0)){
        return self;
    } else {
        
        UIView *hitView = [super hitTest:point withEvent:event];
        
        if (hitView == self) {
            //Test whether any of the passthrough views would handle this touch
            testHits = YES;
            CGPoint superPoint = [self.superview convertPoint:point fromView:self];
            UIView *superHitView = [self.superview hitTest:superPoint withEvent:event];
            testHits = NO;
            
            if ([self isPassthroughView:superHitView]) {
                hitView = superHitView;
            }
        }
        
        return hitView;
    }
}


*/


@end

