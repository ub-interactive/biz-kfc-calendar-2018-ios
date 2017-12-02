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

@interface KFCWebViewController ()<WKUIDelegate, WKNavigationDelegate,WKScriptMessageHandler>

@property(nonatomic,strong) KFCScanNagationView *navigationView;

@property(nonatomic,assign) BOOL isSecondLoading;

@end

@implementation KFCWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationBar];
    
    [self.view addSubview:self.webview];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    
    [self.webview loadRequest:request];
    
    self.isSecondLoading = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)setupNavigationBar{
    
    KFCScanNagationView *navigationView = [[NSBundle mainBundle] loadNibNamed:@"KFCScanNagationView" owner:self options:nil].lastObject;
    navigationView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 64);
    navigationView.backgroundColor = KFC_COLOR_WITH_RGB(214, 50, 58);
    navigationView.visualEffectView.hidden = YES;
    [navigationView.backButton addTarget:self action:@selector(navigationBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [navigationView.closeButton addTarget:self action:@selector(navigationCloseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationView = navigationView;
    [self.view addSubview:navigationView];
    
}



#pragma mark  WKWebViewDelegate

-(void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
//    [self.progressHUD showWithMaskType:WSProgressHUDMaskTypeWhite];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
//    [self.progressHUD dismiss];
    
    self.webview.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.webview.alpha = 1;
    }];
    
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error{
    
    //[WSProgressHUD showErrorWithStatus:@"网络错误，请稍后再试"];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    
    //    if (webView.canGoBack) {
//    self.navigationView.closeButton.hidden = !webView.canGoBack;
        self.navigationView.closeButton.hidden = !self.isSecondLoading;
    //    }
    
    self.isSecondLoading = YES;
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    //    NSLog(@"%@", message.body);
    
//    NSString *urlStr = [message.body objectForKey:@"message"];
    
//    [JXApplication openURL:[NSURL URLWithString:urlStr]];
    
}


-(void)navigationBackButtonClicked{
    
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

-(void)navigationCloseButtonClicked{

    if (!self.isFromMisson) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(WKWebView *)webview{
    
    if (_webview == nil) {
        
        // 创建一个webiview的配置项
        WKWebViewConfiguration *configuretion = [[WKWebViewConfiguration alloc] init];
//         Webview的偏好设置
        configuretion.preferences = [[WKPreferences alloc] init];
        configuretion.preferences.minimumFontSize = 10;
        configuretion.preferences.javaScriptEnabled = YES;
        // 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开
        configuretion.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        // 通过js与webview内容交互配置
        configuretion.userContentController = [[WKUserContentController alloc ]init];
        
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
