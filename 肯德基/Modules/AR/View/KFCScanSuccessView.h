//
//  KFCScanSuccessView.h
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCScanSuccessView : UIView

@property(weak, nonatomic) IBOutlet UIImageView *imageView;

@property(weak, nonatomic) IBOutlet UIButton *goButton;

@property(weak, nonatomic) IBOutlet UIView *tipView;

@property(weak, nonatomic) IBOutlet UILabel *tipLabel;

@property(nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;


@end
