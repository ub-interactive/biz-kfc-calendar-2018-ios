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
#import "KFCRetakeView.h"
#import "KFCStampGroupView.h"
#import "KFCOneMoreView.h"
#import "WXApi.h"
#import "KFCStampGroupModel.h"
#import "KFCShareView.h"
#import "KFCScanViewController.h"
#import "KFCFeatureView.h"

@interface ViewController () <KFCRetakeViewButtonClickDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KFCShowStampGroupViewButtonClickDelegate, KFCOneMoreViewButtonClickDelegate, KFCShareViewButtonClickDelegate>

@property(nonatomic, assign) NSNumber *isFirstLaunch;

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic, strong) AVCaptureDevice *captureDevice;

//AVDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;

//输出图片
@property(nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic, strong) AVCaptureSession *captureSession;

//图像预览层，实时显示捕获的图像
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property(nonatomic, strong) KFCRetakeView *retakeView;

@property(nonatomic, strong) KFCStampGroupView *stampGroupView;

@property(nonatomic, strong) KFCOneMoreView *oneMoreView;

// 贴图前的照片
@property(nonatomic, strong) UIImage *image;

// 贴图后的照片
@property(nonatomic, strong) UIImage *editedImage;

@property(nonatomic, strong) UIImagePickerController *imagePickerController;

@property(nonatomic, strong) UIImageView *cameraImageView;

@property(nonatomic, strong) KFCEditImageView *editImageview;

@property(nonatomic, strong) NSMutableArray *usedImgArr;

@property(nonatomic, strong) KFCShareView *shareView;

// feature
@property(nonatomic, strong) UIView *featureView;

@property(nonatomic, strong) UIScrollView *featureScrollView;


// controllers
@property(nonatomic, strong) KFCScanViewController *kfcScanViewController;

@end

@implementation ViewController {
    UIVisualEffectView *blurView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // check first launch
    self.isFirstLaunch = [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_IS_FIRST_LAUNCH] == nil ? @YES : [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_IS_FIRST_LAUNCH];
    [KFC_USER_DEFAULTS setObject:@NO forKey:KFC_USER_DEFAULT_IS_FIRST_LAUNCH];
    [KFC_USER_DEFAULTS synchronize];

    // init data
    [self getStampGroupData];

    //init UI
    self.navigationController.navigationBar.hidden = YES;
    blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = self.view.bounds;
    blurView.autoresizingMask = (UIViewAutoresizing) (UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight);

    // 启动相机
    [self setupCamera];

    [self.view bringSubviewToFront:self.switchCameraButton];
    [self.view bringSubviewToFront:self.importFromAlbumButton];
    [self.view bringSubviewToFront:self.takePhotoButton];
    [self.view bringSubviewToFront:self.scanButton];
    [self.view bringSubviewToFront:self.infoButton];

    // bind notifications
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(editImageViewActive:) name:KFC_NOTIFICATION_NAME_EDIT_IMAGE_VIEW_ACTIVE object:nil];
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(getStampGroupData) name:KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED_RELOAD_DATA object:nil];

    // show feature pages
    NSString *lastVersion = [KFC_USER_DEFAULTS stringForKey:KFC_USER_DEFAULT_APP_VERSION];
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];

    // 是第一次使用app || 是第一次使用当前版本
//    if (!lastVersion || [lastVersion compare:currentVersion] == NSOrderedAscending) {
//        [KFC_USER_DEFAULTS setObject:currentVersion forKey:KFC_USER_DEFAULT_APP_VERSION];
//        [self showFeatureView];
//    }


    // init child controllers
    self.kfcScanViewController = [[KFCScanViewController alloc] init];

    // image picker controller
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;

    self.imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.imagePickerController.allowsEditing = NO;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startCaptureSessionWithCompletion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopCaptureSessionWithCompletion:nil];
}


- (void)startCaptureSessionWithCompletion:(void (^ __nullable)(BOOL finished))completion {
    blurView.alpha = 1;
    [self.captureSession startRunning];
    [UIView animateWithDuration:0.1f animations:^{
        blurView.alpha = 0;
    }                completion:completion];
}

- (void)stopCaptureSessionWithCompletion:(void (^ __nullable)(BOOL finished))completion {
    blurView.alpha = 0;
    [self.captureSession stopRunning];
    [UIView animateWithDuration:0.1f animations:^{
        blurView.alpha = 1;
    }                completion:completion];
}

- (NSArray *)getLocalData {

    KFCStampGroupModel *kfcStampGroupModel = [[KFCStampGroupModel alloc] init];
    kfcStampGroupModel.name = @"敬请期待";
    kfcStampGroupModel.isNew = 0;
    kfcStampGroupModel.note = @"K记大玩家会不定期推出新贴纸，请关注K记通知和线下活动活动！";
    kfcStampGroupModel.isAvailable = 0;

    return @[kfcStampGroupModel];
}

- (void)getStampGroupData {
    self.stampGroups = [[NSMutableArray alloc] init];
    [self.stampGroups addObjectsFromArray:[self getLocalData]];

    [[AFHTTPSessionManager manager] GET:KFC_URL_CALENDAR_NEW_STAMPS parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self.stampGroups removeAllObjects];
        self.stampGroups = [KFCStampGroupModel mj_objectArrayWithKeyValuesArray:responseObject];
        [self.stampGroups addObjectsFromArray:[self getLocalData]];
    }                           failure:^(NSURLSessionTask *operation, NSError *error) {

    }];
}

- (void)setupCamera {

    self.captureDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];

    self.captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];

    self.captureSession = [[AVCaptureSession alloc] init];

    //拿到的图像的大小可以自行设定
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;

    //输入输出设备结合
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }

    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        [self.captureSession addOutput:self.captureStillImageOutput];
    }

    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.view.layer addSublayer:self.previewLayer];
    [self.view addSubview:blurView];

    if ([self.captureDevice lockForConfiguration:nil]) {
        //自动闪光灯
        if ([self.captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }

        [self.captureDevice unlockForConfiguration];
    }

}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    for (AVCaptureDevice *device in devices)
        if (device.position == position) {
            return device;
        }
    return nil;
}

// 拍照
- (IBAction)takePhotoButtonClicked:(id)sender {

    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        NSLog(@"拍照失败!");
        return;
    }

    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {

        if (imageDataSampleBuffer == nil) return;

        [self stopCaptureSessionWithCompletion:nil];

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

        self.image = [UIImage imageWithData:imageData];

        [UIView animateWithDuration:0 animations:^{
            [self addRetakeView:self.image];
        }                completion:^(BOOL finished) {
            [self addStampGroupView];
        }];

    }];
}


- (void)addRetakeView:(UIImage *)image {

    //  重新拍照 & 保存 的蒙版
    self.retakeView = [[NSBundle mainBundle] loadNibNamed:@"KFCRetakeView" owner:self options:nil].lastObject;
    self.retakeView.frame = self.view.bounds;

    self.retakeView.delegate = self;
    [self.view addSubview:self.retakeView];

    // 根据图片比例 计算高度
    CGFloat ration = image.size.height / image.size.width;
    // 显示的高度
    CGFloat realHeight = SCREEN_WIDTH * ration;

    self.cameraImageView = [[UIImageView alloc] initWithFrame:self.retakeView.bounds];
    self.cameraImageView.backgroundColor = [UIColor orangeColor];
    self.cameraImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.cameraImageView.userInteractionEnabled = YES;

    self.cameraImageView.height = floorf(realHeight);       // 向下取整, 不然截图的时候 会有底部会有白边
    self.cameraImageView.center = self.retakeView.center;

    self.cameraImageView.image = self.image;
    [self.retakeView addSubview:self.cameraImageView];
    [self.retakeView sendSubviewToBack:self.cameraImageView];

    self.switchCameraButton.hidden = YES;
    self.importFromAlbumButton.hidden = YES;
    self.takePhotoButton.hidden = YES;
    self.infoButton.hidden = YES;
}


// 切换摄像头
- (IBAction)switchCameraButtonClicked:(id)sender {

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
        AVCaptureDevicePosition position = [[self.captureDeviceInput device] position];
        if (position == AVCaptureDevicePositionFront) {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }

        //生成新的输入
        [self stopCaptureSessionWithCompletion:nil];
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.captureDeviceInput];

            if ([self.captureSession canAddInput:newInput]) {
                [self.captureSession addInput:newInput];
                self.captureDeviceInput = newInput;
            } else {
                [self.captureSession addInput:self.captureDeviceInput];
            }
            [self.captureSession commitConfiguration];
            [self startCaptureSessionWithCompletion:nil];

        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }

    }


}


// 相册
- (IBAction)importFromAlbumButtonClicked:(id)sender {
    [self stopCaptureSessionWithCompletion:(void (^)(BOOL)) ^{
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }];
}

// 扫一扫
- (IBAction)scanButtonClicked:(UIButton *)sender {
    [self stopCaptureSessionWithCompletion:(void (^)(BOOL)) ^{
        [self.navigationController pushViewController:self.kfcScanViewController animated:YES];
    }];
}


#pragma mark UIImagePickerControllerDelegate

//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *, id> *)editingInfo {
    self.image = image;
    [self addRetakeView:self.image];

    [self dismissViewControllerAnimated:YES completion:^{
        // 自动显示贴纸页面
        [self stopCaptureSessionWithCompletion:(void (^)(BOOL)) ^{
            [self addStampGroupView];
        }];

    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:^{
        [self startCaptureSessionWithCompletion:nil];
    }];
}

#pragma mark - KFCRetakeViewButtonClickDelegate

- (void)retakeViewButtonClicked:(NSInteger)buttonTag {

    if (buttonTag == 1) {       // 重拍 或  再拍一张

        self.switchCameraButton.hidden = NO;
        self.importFromAlbumButton.hidden = NO;
        self.takePhotoButton.hidden = NO;
        self.infoButton.hidden = NO;

        [self.retakeView removeFromSuperview];
        [self.cameraImageView removeFromSuperview];
        [self.oneMoreView removeFromSuperview];

        [self startCaptureSessionWithCompletion:nil];

    } else if (buttonTag == 2) {      // 保存

        self.retakeView.retakeButton.hidden = YES;
        self.retakeView.saveButton.hidden = YES;
        self.retakeView.pasterButton.hidden = YES;

        self.cameraImageView.clipsToBounds = YES;

        [UIView animateWithDuration:0 animations:^{
            for (UIView *subView in self.cameraImageView.subviews) {
                if ([subView isKindOfClass:KFCEditImageView.class]) {
                    KFCEditImageView *imgView = (KFCEditImageView *) subView;
                    imgView.deleteButton.hidden = YES;
                    imgView.dragButton.hidden = YES;
                    imgView.backgroundView.hidden = YES;
                    [imgView.border removeFromSuperlayer];
                }
            }
        }                completion:^(BOOL finished) {

            // 截个屏
            self.editedImage = [self captureImageFromView:self.cameraImageView];

            UIImageWriteToSavedPhotosAlbum(self.editedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }];

    } else {      // 贴纸

        [self addStampGroupView];
    }
}

// 添加stamp group
- (void)addStampGroupView {

    if (self.stampGroups.count && !self.stampGroupView.data.count) {
        self.stampGroupView.data = self.stampGroups;
    }
    [self.view addSubview:self.stampGroupView];
    [UIView animateWithDuration:0.3f animations:^{
        self.stampGroupView.x = 0;
    }];
}


// 图片和视频保存完毕后的回调

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    NSString *msg = @"图片保存成功! ";
    if (error != NULL) {
        msg = @"图片保存失败";
    }
    [KFCProgressHUD showWithString:msg inView:self.view];

    if (error != NULL) return;

    // 保存完了,  显示 再拍一张 & 分享 按钮

    self.oneMoreView = [[NSBundle mainBundle] loadNibNamed:@"KFCOneMoreView" owner:self options:nil].lastObject;
    self.oneMoreView.frame = self.view.bounds;
    self.oneMoreView.delegate = self;

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
- (UIImage *)captureImageFromView:(UIView *)view {

    CGRect frame = view.bounds;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);  // 原图  清晰
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


// 再拍一张
- (void)oneMoreViewButtonClicked:(UIButton *)button {

    if (button.tag == 10) {     // 分享

        self.shareView = [[NSBundle mainBundle] loadNibNamed:@"KFCShareView" owner:self options:nil].lastObject;
        self.shareView.frame = [UIScreen mainScreen].bounds;
        self.shareView.y = 150;
        self.shareView.delegate = self;
        [self.view addSubview:self.shareView];

        [UIView animateWithDuration:0.3f animations:^{
            self.shareView.y = 0;
        }];

    } else {     // 再拍一次

        [button removeFromSuperview];
        // 重拍
        [self retakeViewButtonClicked:button.tag];

    }
}


- (void)shareViewButtonClicked:(UIButton *)button {


    if (button.tag == 0) {      // 取消

    } else if (button.tag == 1) {     // 朋友圈

        [self shareToWeChatWithType:WXSceneTimeline];

    } else if (button.tag == 2) {     //  好友

        [self shareToWeChatWithType:WXSceneSession];

    } else if (button.tag == 4) {     // cover  button


    }

    [UIView animateWithDuration:0.3f animations:^{
        self.shareView.y = 150;
    }                completion:^(BOOL finished) {
        [self.shareView removeFromSuperview];
    }];
}


- (void)shareToWeChatWithType:(int)scene {

    if (![WXApi isWXAppInstalled]) {
        [KFCProgressHUD showWithString:@"请先下载微信" inView:self.view];
        return;
    }

    WXMediaMessage *message = [WXMediaMessage message];

    [message setThumbImage:[self.editedImage resizedImageToFitInSize:CGSizeMake(150, 150) scaleIfSmaller:YES]];

    WXImageObject *imageObject = [WXImageObject object];

    imageObject.imageData = UIImageJPEGRepresentation(self.editedImage, 1);
    message.mediaObject = imageObject;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;

    req.scene = scene;      // WXSceneSession

    [WXApi sendReq:req];
}


#pragma mark - KFCPasterViewButtonClickDelegate

// 长按图片  拖出来

- (void)stampGroupViewDidClickedWithImageName:(NSString *)imgName {

    CGFloat imgW = [UIScreen mainScreen].bounds.size.width / 2;
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgName];

    // 图片的 高度和宽度
    CGFloat imgWid = CGImageGetWidth(cachedImage.CGImage);
    CGFloat imgHei = CGImageGetHeight(cachedImage.CGImage);

    if (imgHei == 0.0) return;

    CGFloat realHeight = imgW * (imgHei / imgWid);

    self.editImageview = [[KFCEditImageView alloc] initWithFrame:CGRectMake(0, 0, imgW, realHeight)];
    self.editImageview.center = self.cameraImageView.center;
    self.editImageview.y = self.cameraImageView.height / 2 - self.editImageview.height / 2;
    self.editImageview.stampImageView.image = cachedImage;

    // 设置图片name, 发通知过来可删除
    self.editImageview.imageName = imgName;
    [self.cameraImageView addSubview:self.editImageview];
    [KFCEditImageView setActiveStampView:self.editImageview];

    self.retakeView.saveButton.hidden = YES;
    self.retakeView.retakeButton.hidden = YES;

    // 给retakeview 加个点击手势, 点击的时候让 editImageView 的active 变成NO , 同时隐藏  返回&保存  按钮

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retakeViewTap:)];

    [self.retakeView addGestureRecognizer:tap];

    // 拖动完成后 将paster view  移除
    [self.stampGroupView removeFromSuperview];
    self.stampGroupView.x = 145;

}


- (void)retakeViewTap:(UITapGestureRecognizer *)tap {

    [KFCEditImageView setActiveStampView:nil];

    self.retakeView.retakeButton.hidden = NO;
    self.retakeView.saveButton.hidden = NO;
}

- (void)editImageViewActive:(NSNotification *)noti {

    self.retakeView.retakeButton.hidden = (noti.object != nil);
    self.retakeView.saveButton.hidden = (noti.object != nil);
}

- (KFCStampGroupView *)stampGroupView {

    if (!_stampGroupView) {

        _stampGroupView = [[NSBundle mainBundle] loadNibNamed:@"KFCStampGroupView" owner:self options:nil].lastObject;
        _stampGroupView.frame = CGRectMake(145, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _stampGroupView.delegate = self;

    }
    return _stampGroupView;
}

/**************     特性页面     **************/
- (void)showFeatureView {

    self.featureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:self.featureView];

    UIView *videoView = [[UIView alloc] initWithFrame:self.featureView.bounds];
    [self.featureView addSubview:videoView];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"feature" ofType:@"mp4"];
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

    self.featureScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.featureScrollView.contentSize = CGSizeMake(4 * SCREEN_WIDTH, 0);
    self.featureScrollView.pagingEnabled = YES;
    self.featureScrollView.bounces = NO;
    self.featureScrollView.showsHorizontalScrollIndicator = NO;

    [self.featureView addSubview:self.featureScrollView];
    self.featureView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.featureView.alpha = 1;
    }];
    
    [self setScrollViewImages:self.featureScrollView];
}

- (void)setScrollViewImages:(UIScrollView *)newfeatureScrollView {

    for (int i = 0; i < 4; i++) {

        KFCFeatureView *newFeaturePageView = [[NSBundle mainBundle] loadNibNamed:@"KFCFeatureView" owner:self options:nil].lastObject;
        newFeaturePageView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

        newFeaturePageView.pageControl.currentPage = i;
        newFeaturePageView.iconImageView.hidden = (i != 0);

        newFeaturePageView.nextPageButton.tag = i;
        [newFeaturePageView.nextPageButton addTarget:self action:@selector(featureNextPageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [newFeaturePageView.skipButton addTarget:self action:@selector(featureSkipButtonClicked) forControlEvents:UIControlEventTouchUpInside];

        if (i == 0) {

            newFeaturePageView.titleLabel.text = @"欢迎来到 K记大玩家";
            newFeaturePageView.descLabel.text = @"本上校为你带来了整整一年的惊喜…";
        } else if (i == 1) {

            newFeaturePageView.titleLabel.text = @"AR黑科技 扫扫有惊喜";
            newFeaturePageView.descLabel.text = @"玩转AR黑科技 扫海报 扫汉堡…\n扫得越多 惊喜越多";
        } else if (i == 2) {

            newFeaturePageView.titleLabel.text = @"收集K记贴纸 秀翻朋友圈";
            newFeaturePageView.descLabel.text = @"收集肯德基限定精美贴纸\n分享朋友圈秀出独一无二的你";
        } else if (i == 3) {

            newFeaturePageView.titleLabel.text = @"参加主题活动 赢惊喜礼物";
            newFeaturePageView.descLabel.text = @"开启消息推送获取肯德基最新活动讯息\n参加店内活动赢取免费礼物";
        }

        if (i == 3) {       // 开始 按钮
            [newFeaturePageView.nextPageButton setImage:[UIImage imageNamed:@"feature-start"] forState:UIControlStateNormal];
        }

        [newfeatureScrollView addSubview:newFeaturePageView];
    }

}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
}

/**
 *   下一页  or  开始
 */
- (void)featureNextPageButtonClicked:(UIButton *)sender {
    [self.featureScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * (sender.tag + 1), 0) animated:YES];
    if (sender.tag == 3) {      // 开始 按钮
        [self featureSkipButtonClicked];
    }
}

/**
 *   跳过
 */
- (void)featureSkipButtonClicked {
    [self.featureView removeFromSuperview];
}


- (void)dealloc {
    [KFC_NOTIFICATION_CENTER removeObserver:self];
}


- (IBAction)infoButtonClicked:(id)sender {
    [self showFeatureView];
}


@end

