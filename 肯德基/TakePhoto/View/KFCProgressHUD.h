//
//  KFCProgressHUD.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCProgressHUD : UIView


@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;


@property (weak, nonatomic) IBOutlet UIImageView *tipsIcon;


+(void)showWithString:(NSString *)string inView:(UIView *)view;

@end
