//
//  KFCWebViewController.m
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCWebViewController.h"
#import "KFCConfig.h"
#import "KFCScanNagationView.h"
#import "WXApi.h"
#import "KFCScanViewController.h"

@interface KFCWebViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property(nonatomic, strong) KFCScanNagationView *navigationView;

@property(nonatomic, assign) BOOL isSecondLoading;

@end

@implementation KFCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    //setup navigation bar
    KFCScanNagationView *navigationView = [[NSBundle mainBundle] loadNibNamed:@"KFCScanNavigationView" owner:self options:nil].lastObject;
    navigationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
    navigationView.backgroundColor = KFC_COLOR_WITH_RGB(214, 50, 58);
    navigationView.visualEffectView.hidden = YES;
    [navigationView.backButton addTarget:self action:@selector(navigationBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [navigationView.closeButton addTarget:self action:@selector(navigationCloseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationView = navigationView;
    [self.view addSubview:navigationView];


    [self.view addSubview:self.webview];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [self.webview loadRequest:request];

    self.isSecondLoading = NO;
}

#pragma mark  WKWebViewDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {

//    [self.progressHUD showWithMaskType:WSProgressHUDMaskTypeWhite];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {

//    [self.progressHUD dismiss];

    self.webview.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.webview.alpha = 1;
    }];

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error {

    //[WSProgressHUD showErrorWithStatus:@"网络错误，请稍后再试"];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];

    if ([scheme isEqualToString:@"kc2018"]) {

        if ([URL.host isEqualToString:@"scan"]) {
            UINavigationController *navigationController = (UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;

            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[KFCScanViewController class]]) {
                    [navigationController popToViewController:vc animated:YES];
                    decisionHandler(WKNavigationActionPolicyAllow);
                    return;
                }
            }

            KFCScanViewController *viewController = [[KFCScanViewController alloc] init];
            [navigationController pushViewController:viewController animated:YES];

        } else {

            //        [[UIApplication sharedApplication] openURL:URL];

            //        kc2018://share?type=0&url=https://www.apple.com&thumb=http://www.apple.com/apple.png&title=标题

            NSMutableDictionary *dic = [self getURLParametersWithUrl:URL];

            NSLog(@"NSMutableDictionary  ==  %@", dic);

            NSString *type = dic[@"type"];
            NSString *title = dic[@"title"];
            NSString *thumb = dic[@"thumb"];
            NSString *url = dic[@"url"];

            if (![WXApi isWXAppInstalled]) {
                //            [KFCProgressHUD showWithString:@"未检测到分享源" inView:self.view];
                return;
            }

            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            [message setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]]]];

            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = url;
            message.mediaObject = ext;

            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;

            if (type.intValue == 1) {
                req.scene = WXSceneSession;      // 好友
            } else {
                req.scene = WXSceneTimeline;      // 朋友圈
            }

            [WXApi sendReq:req];
        }

    } else {

        //    if (webView.canGoBack) {
        //    self.navigationView.closeButton.hidden = !webView.canGoBack;
        self.navigationView.closeButton.hidden = !self.isSecondLoading;
        //    }

        self.isSecondLoading = YES;
    }

    decisionHandler(WKNavigationActionPolicyAllow);

}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

    NSLog(@"%@", message.body);

//    NSString *urlStr = [message.body objectForKey:@"message"];


//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];

}

- (NSMutableDictionary *)getURLParametersWithUrl:(NSURL *)url {

    // 查找参数
    NSString *urlStr = url.absoluteString;

    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];

    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {

        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];

        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }

            id existValue = [params valueForKey:key];

            if (existValue != nil) {

                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];

                    [params setValue:items forKey:key];
                } else {

                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }

            } else {

                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数

        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];

        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }

        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];

        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }

        // 设置值
        [params setValue:value forKey:key];
    }

    return params;
}


- (void)navigationBackButtonClicked {

    if (self.webview.canGoBack) {
        [self.webview goBack];
        return;
    }
    if (!self.isFromMisson) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)navigationCloseButtonClicked {

    if (!self.isFromMisson) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }

    [self.navigationController popViewControllerAnimated:YES];
}


- (WKWebView *)webview {

    if (_webview == nil) {

        // 创建一个webiview的配置项
        WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc] init];
//         Webview的偏好设置
        configuretion.preferences = [[WKPreferences alloc] init];
        configuretion.preferences.minimumFontSize = 10;
        configuretion.preferences.javaScriptEnabled = YES;
        // 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开
        configuretion.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        // 通过js与webview内容交互配置
        configuretion.userContentController = [[WKUserContentController alloc] init];

        WKUserScript *scipt = [[WKUserScript alloc] initWithSource:@"function showAlert() { alert('在载入webview时通过Swift注入的JS方法'); }" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [configuretion.userContentController addUserScript:scipt];
        [configuretion.userContentController addScriptMessageHandler:self name:@"kfc"];

        _webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) configuration:configuretion];
        _webview.backgroundColor = [UIColor clearColor];
        _webview.navigationDelegate = self;
        _webview.UIDelegate = self;

        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
//            _webview.customUserAgent = @"User-Agent:RongCloud/4.6 (iOS; 9.3) tdrvipksr5h35 com.hongdianapp.HongDianjinxiang";
        }
    }
    return _webview;
}


@end
