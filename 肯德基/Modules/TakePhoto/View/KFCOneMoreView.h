//
//  KFCOneMoreView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KFCOneMoreViewButtonClickDelegate <NSObject>

@required

- (void)oneMoreViewButtonClicked:(UIButton *)button;


@end

@interface KFCOneMoreView : UIView


@property(weak, nonatomic) IBOutlet UIImageView *shareTipsImageView;

@property(weak, nonatomic) IBOutlet UIButton *shareButton;


@property(weak, nonatomic) IBOutlet UIButton *oneMoreButton;


@property(nonatomic, weak) id <KFCOneMoreViewButtonClickDelegate> delegate;

@end
