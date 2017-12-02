//
//  KFCScanNagationView.h
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCScanNagationView : UIView

//  返回
@property (weak, nonatomic) IBOutlet UIButton *backButton;

//  关闭
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;



@end
