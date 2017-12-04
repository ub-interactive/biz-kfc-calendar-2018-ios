//
//  KFCWebViewController.h
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface KFCWebViewController : UIViewController

@property(strong, nonatomic) WKWebView *webview;

@property(nonatomic, copy) NSString *urlStr;

@property(nonatomic, assign) BOOL isFromMisson;

@end
