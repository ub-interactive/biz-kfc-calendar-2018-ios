//=============================================================================================================================
//
// Copyright (c) 2015-2017 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "KFCScanViewController.h"
#import "KFCConfig.h"
#import "OpenGLView.h"
#import "KFCScanNagationView.h"
#import "QRView.h"
#import "KFCScanSuccessView.h"
#import "KFCWebViewController.h"
#import "KFCScanSuccessModel.h"
#import <AudioToolbox/AudioToolbox.h>

@interface KFCScanViewController ()

@property(nonatomic, strong) QRView *qrView;

@property(nonatomic, strong) KFCScanSuccessModel *successModel;

@property(nonatomic, strong) KFCScanNagationView *navigationView;

@property(nonatomic, strong) KFCScanSuccessView *scanSuccessView;

@end

@implementation KFCScanViewController {
    OpenGLView *glView;
    SystemSoundID scanSuccessSound;
}

- (void)loadView {
    self->glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    [self->glView setOrientation:self.interfaceOrientation];
    self.view = self->glView;
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(arScanSuccess:) name:KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置 navigation bar
    KFCScanNagationView *navigationView = [[NSBundle mainBundle] loadNibNamed:@"KFCScanNavigationView" owner:self options:nil].lastObject;
    navigationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
    [navigationView.backButton addTarget:self action:@selector(navigationBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navigationView];
    self.navigationView = navigationView;
    
    // load sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"scan-success" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &scanSuccessSound);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.view addSubview:self.qrView];
    [self.view bringSubviewToFront:self.navigationView];

    [self.scanSuccessView removeFromSuperview];
    self.scanSuccessView = nil;

    [self->glView startCamera];
    [self->glView startTracker];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self->glView stopTracker];
}

- (void)dealloc {
    [self->glView stopTracker];
    [self->glView stopCamera];
    [KFC_NOTIFICATION_CENTER removeObserver:self];
    AudioServicesDisposeSystemSoundID(scanSuccessSound);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self->glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self->glView setOrientation:toInterfaceOrientation];
}

/*
    识别成功后的处理
 */
- (void)arScanSuccess:(NSNotification *)notification {
    [self->glView stopTracker];

    AudioServicesPlaySystemSound(scanSuccessSound);
    
    // 识别完成后  先显示一个loading, 去网络请求, 下载完完图片后才显示view, 如果后台不给url , 则直接返回拍照页面, 如果给了, 则进入webviewcontroller 加载url
    // 添加  扫描成功后的view
    self.scanSuccessView = [[NSBundle mainBundle] loadNibNamed:@"KFCScanSuccessView" owner:self options:nil].lastObject;
    self.scanSuccessView.frame = self.view.bounds;
    [self.scanSuccessView.goButton addTarget:self action:@selector(scanSuccessViewGoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.scanSuccessView];

    [self.view bringSubviewToFront:self.navigationView];

    NSString *deviceId = [[UIDevice currentDevice] identifierForVendor].UUIDString;

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", KFC_URL_CALENDAR_COMPLETE_TASKS, deviceId, notification.object];

    [[AFHTTPSessionManager manager] GET:urlStr parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        self.successModel = [KFCScanSuccessModel mj_objectWithKeyValues:responseObject];

        if (self.successModel.completionUrl) {
            self.scanSuccessView.goButton.titleLabel.text = @"去看看";
            [self.scanSuccessView.goButton setTitle:@"去看看" forState:UIControlStateNormal];
        } else {
            self.scanSuccessView.goButton.titleLabel.text = @"知道了";
            [self.scanSuccessView.goButton setTitle:@"知道了" forState:UIControlStateNormal];
        }

        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.successModel.completionResource] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {
        }                                                   completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, BOOL finished) {

            if (finished) {

                [self.qrView removeFromSuperview];

                [self.scanSuccessView.loadingIndicator stopAnimating];
                self.scanSuccessView.loadingIndicator.hidden = YES;

                self.scanSuccessView.imageView.hidden = NO;
                self.scanSuccessView.tipView.hidden = NO;
                self.scanSuccessView.imageView.image = image;

                if (self.successModel.completionDescription && ![self.successModel.completionDescription isEqualToString:@""]) {

                    // 计算文字高度    tips view  高度是 40 + descriptionRect.height + 30  30是上下margin
                    CGRect descriptionRect = [self rectWithString:self.successModel.completionDescription];
                    self.scanSuccessView.heightConstraint.constant = 40 + descriptionRect.size.height + 30;

                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.successModel.completionDescription];
                    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style.lineSpacing = 3;
                    style.alignment = NSTextAlignmentLeft;

                    NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName: UIColor.blackColor,
                            NSParagraphStyleAttributeName: style
                    };
                    [attributedString addAttributes:textFontAttributes range:NSMakeRange(0, self.successModel.completionDescription.length)];
                    self.scanSuccessView.tipLabel.attributedText = attributedString;
                } else {
                    // tipsview 高度 40
                    self.scanSuccessView.heightConstraint.constant = 40;
                }

            }
        }];

        //   扫描成功  完成任务,  刷新数据
        [KFC_NOTIFICATION_CENTER postNotificationName:KFC_NOTIFICATION_NAME_AR_SCAN_SUCCEED_RELOAD_DATA object:nil];
    }                           failure:^(NSURLSessionTask *operation, NSError *error) {

    }];
}

- (CGRect)rectWithString:(NSString *)str {

    if (!str || [str isEqualToString:@""]) return CGRectZero;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3;
    style.alignment = NSTextAlignmentLeft;

    NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName: UIColor.blackColor,
            NSParagraphStyleAttributeName: style
    };

    [attributedString addAttributes:textFontAttributes range:NSMakeRange(0, str.length)];

    CGRect titleRect = [attributedString boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 50 * 2 - 12 * 2, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    return titleRect;
}

/*
    去看看
 */

- (void)scanSuccessViewGoButtonClicked:(UIButton *)sender {

    [self.scanSuccessView removeFromSuperview];

    // 根据后台返回的数据   来决定去哪个页面

    //如果后台不给url , 则直接返回拍照页面, 如果给了, 则进入web view controller 加载url
    if (!self.successModel.completionUrl) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self pushWebViewControllerWithUrlStr:self.successModel.completionUrl isFromTasks:NO];
    }
}

/*
    返回按钮
 */

- (void)navigationBackButtonClicked {

    [self.navigationController popViewControllerAnimated:YES];
}

/*
    任务列表
 */

- (void)qrViewTasksButtonClicked {
    [self pushWebViewControllerWithUrlStr:@"https://www.youbohudong.com/biz/vip/kfc/calendar-2018/tasks" isFromTasks:YES];
    [self.scanSuccessView removeFromSuperview];
    self.scanSuccessView = nil;
}


- (void)pushWebViewControllerWithUrlStr:(NSString *)urlStr isFromTasks:(BOOL)isFromTasks {
    KFCWebViewController *webViewController = [KFCWebViewController new];
    webViewController.urlStr = urlStr;
    webViewController.isFromTasks = isFromTasks;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)qrviewScanButtonClicked:(NSInteger)tag {

    [UIView animateWithDuration:0.3 animations:^{
        [self->glView stopCamera];
    }                completion:^(BOOL finished) {
        if (finished) [self->glView startCamera];
    }];

}

- (QRView *)qrView {

    if (!_qrView) {
        _qrView = [[QRView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _qrView.backgroundColor = [UIColor clearColor];
        _qrView.transparentArea = CGSizeMake(KFC_CONST_QRVIEW_TRANSPARENT_AREA_WIDTH, KFC_CONST_QRVIEW_TRANSPARENT_AREA_WIDTH);

        WS(weakSelf);

        [_qrView setQrViewScanButtonClickedBlock:^(NSInteger tag) {

            [weakSelf qrviewScanButtonClicked:tag];

        }];

        [_qrView setQrViewSureButtonClickedBlock:^(NSString *qrStr) {

            [weakSelf qrViewTasksButtonClicked];
        }];

    }
    return _qrView;
}


@end
