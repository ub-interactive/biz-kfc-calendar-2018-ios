//
//  KFCScanSuccessView.h
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCScanSuccessView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *scanSuccessImageView;

@property (weak, nonatomic) IBOutlet UIButton *toSeeButton;

@property (weak, nonatomic) IBOutlet UIView *scanSuccessTipsView;

@property (weak, nonatomic) IBOutlet UILabel *scanSuccessNoteLabel;

@property(nonatomic,strong) UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanSucessTipsViewHeightConstraint;


@end
