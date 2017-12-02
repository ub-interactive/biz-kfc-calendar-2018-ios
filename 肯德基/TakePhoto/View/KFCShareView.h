//
//  KFCShareView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/8.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KFCShareViewButtonClickDelegate <NSObject>

@required

-(void)shareViewButtonClicked:(UIButton *)button;


@end


@interface KFCShareView : UIView

@property (weak, nonatomic) IBOutlet UIButton *wechatFriend;

@property (weak, nonatomic) IBOutlet UIButton *wechatCircle;


@property (weak, nonatomic) IBOutlet UIButton *cancleButton;

@property(nonatomic,weak) id<KFCShareViewButtonClickDelegate> delegate;


@end
