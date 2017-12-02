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

@interface KFCScanViewController ()

@property(nonatomic, strong) QRView *qrView;

@property(nonatomic, strong) KFCScanSuccessModel *successModel;

@property(nonatomic, strong) KFCScanNagationView *navigationView;

@property(nonatomic, strong) KFCScanSuccessView *scanSuccessView;


@end

@implementation KFCScanViewController {
    OpenGLView *glView;
}

- (void)loadView {
    self->glView = [[OpenGLView alloc] initWithFrame:CGRectZero];
    self.view = self->glView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self->glView setOrientation:self.interfaceOrientation];


    // 设置naviagtionbar
    [self setupNavigationBar];

    // 之前是写在 viewwillappear里的， 不过会有问题， 会重复加载， 导致白屏
    // 解决方法， 直接不让 glview stop 了， 实际上 glview 一直在后台识别， 只不过当这个页面不显示的时候不接受识别成功的回调    笨人有笨法😂
    [self->glView start];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self.view addSubview:self.qrView];

    [self.view bringSubviewToFront:self.navigationView];

    // 识别成功后的通知
    [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(arScanSuccess:) name:KFC_NOTIFICATION_NAME_AR_RECOGNISE_SUCCEED object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];

//    [self->glView stop];

    // 识别成功后的通知
    [KFC_NOTIFICATION_CENTER removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self.qrView removeFromSuperview];
//    self.qrView = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self->glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self->glView setOrientation:toInterfaceOrientation];
}


- (void)setupNavigationBar {

    KFCScanNagationView *navigationView = [[NSBundle mainBundle] loadNibNamed:@"KFCScanNagationView" owner:self options:nil].lastObject;
    navigationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);

    [navigationView.backButton addTarget:self action:@selector(navigationBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:navigationView];

    self.navigationView = navigationView;
}

/*
    识别成功后的处理
 */
- (void)arScanSuccess:(NSNotification *)noti {

    // 如果当前页面不显示， 则不接收 识别成功的回调，但实际上 一直还在后台识别中。。。
    if (self.scanSuccessView) return;

    if ([self.view.subviews containsObject:self.scanSuccessView]) return;

    // 识别完成后  先显示一个loading, 去网络请求, 下载完完图片后才显示view, 如果后台不给url , 则直接返回拍照页面, 如果给了, 则进入webviewcontroller 加载url
    // 添加  扫描成功后的view
    self.scanSuccessView = [[NSBundle mainBundle] loadNibNamed:@"KFCScanSuccessView" owner:self options:nil].lastObject;
    self.scanSuccessView.frame = self.view.bounds;
    [self.scanSuccessView.toSeeButton addTarget:self action:@selector(scanSuccessViewToseeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.scanSuccessView];

    [self.view bringSubviewToFront:self.navigationView];

    NSString *deviceId = [[UIDevice currentDevice] identifierForVendor].UUIDString;

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", KFC_URL_CALENDAR_COMPLETE_TASKS, deviceId, noti.object];

    NSLog(@"urlStr  ==   %@", urlStr);

    [[AFHTTPSessionManager manager] GET:urlStr parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"KFC_URL_CALENDAR_COMPLETE_TASKS   JSON: %@", responseObject);

        self.successModel = [KFCScanSuccessModel mj_objectWithKeyValues:responseObject];

//        self.successModel.completionUrl = nil;

        if (self.successModel.completionUrl) {
            self.scanSuccessView.toSeeButton.titleLabel.text = @"去看看";
            [self.scanSuccessView.toSeeButton setTitle:@"去看看" forState:UIControlStateNormal];
        } else {
            self.scanSuccessView.toSeeButton.titleLabel.text = @"知道了";
            [self.scanSuccessView.toSeeButton setTitle:@"知道了" forState:UIControlStateNormal];
        }

        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.successModel.completionResource] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

        }                                                   completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, BOOL finished) {

            if (finished) {

                [self.qrView removeFromSuperview];

                [self.scanSuccessView.indicator stopAnimating];
                self.scanSuccessView.indicator.hidden = YES;

                self.scanSuccessView.scanSuccessImageView.hidden = NO;
                self.scanSuccessView.scanSuccessTipsView.hidden = NO;

                self.scanSuccessView.scanSuccessImageView.image = image;

                if (self.successModel.completionDescription && ![self.successModel.completionDescription isEqualToString:@""]) {

                    // 计算文字高度    tips view  高度是 40 + descriptionRect.height + 30  30是上下margin
                    CGRect descriptionRect = [self rectWithString:self.successModel.completionDescription];
                    self.scanSuccessView.scanSucessTipsViewHeightConstraint.constant = 40 + descriptionRect.size.height + 30;

                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.successModel.completionDescription];
                    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    style.lineSpacing = 3;
                    style.alignment = NSTextAlignmentLeft;

                    NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName: UIColor.blackColor,
                            NSParagraphStyleAttributeName: style
                    };
                    [attributedString addAttributes:textFontAttributes range:NSMakeRange(0, self.successModel.completionDescription.length)];
                    self.scanSuccessView.scanSuccessNoteLabel.attributedText = attributedString;
                } else {

                    // tipsview 高度 40
                    self.scanSuccessView.scanSucessTipsViewHeightConstraint.constant = 40;
                }

            }
        }];

        //   扫描成功  完成任务,  刷新数据
        [KFC_NOTIFICATION_CENTER postNotificationName:KFC_NOTIFICATION_NAME_AR_RECOGNISE_SUCCEED_RELOAD_DATA object:nil];


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

    //    NSLog(@"titleRect.size.height  ==  %.2f", titleRect.size.height);

    return titleRect;
}

/*
    去去看看
 */

- (void)scanSuccessViewToseeButtonClicked:(UIButton *)sender {

    [self.scanSuccessView removeFromSuperview];

    // 根据后台返回的数据   来决定去哪个页面

    //如果后台不给url , 则直接返回拍照页面, 如果给了, 则进入webviewcontroller 加载url

    if (!self.successModel.completionUrl) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }

    [self pushWebViewControllerWithUrlStr:self.successModel.completionUrl isFromMisson:NO];

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

- (void)qrViewMissonListButtonClicked {

    [self pushWebViewControllerWithUrlStr:@"https://www.youbohudong.com/biz/vip/kfc/calendar-2018/tasks" isFromMisson:YES];

    [self.scanSuccessView removeFromSuperview];
    self.scanSuccessView = nil;


}


- (void)pushWebViewControllerWithUrlStr:(NSString *)urlStr isFromMisson:(BOOL)isMission {

    KFCWebViewController *webViewController = [KFCWebViewController new];
    webViewController.urlStr = urlStr;
    webViewController.isFromMisson = isMission;
    [self.navigationController pushViewController:webViewController animated:YES];


}

- (void)qrviewScanButtonClicked:(NSInteger)tag {

    [UIView animateWithDuration:0.3 animations:^{
        [self->glView stop];
    }                completion:^(BOOL finished) {
        if (finished) [self->glView start];
    }];

    if (tag == 100) {       // 点击扫图片



    } else if (tag == 200) {      // 点击扫图片



    }

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

//            [weakSelf handleScanResultWithQrcodeStr:qrStr];
            [weakSelf qrViewMissonListButtonClicked];
        }];

    }
    return _qrView;
}


@end
