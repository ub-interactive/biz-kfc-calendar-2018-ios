//
//  KFCFeatureView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/26.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFCFeatureView : UIView

@property(nonatomic, weak) IBOutlet UIView *videoView;

@property(nonatomic, weak) IBOutlet UIButton *nextPageButton;

@property(nonatomic, weak) IBOutlet UIButton *skipButton;

@property(nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property(nonatomic, weak) IBOutlet UILabel *descLabel;

@property(nonatomic, weak) IBOutlet UILabel *titleLabel;

@property(nonatomic, weak) IBOutlet UIImageView *iconImageView;


@end
