//
//  KFCPasterTableViewCell.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFCStampsModel.h"

static NSString *KFCPasterTableViewCellReusedId = @"KFCPasterTableViewCell";

@interface KFCPasterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *coverImageBgView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

//@property (weak, nonatomic) IBOutlet UIImageView *usedIcon;

//@property (weak, nonatomic) IBOutlet UIView *usedBgView;

@property (weak, nonatomic) IBOutlet UILabel *loadingTitleLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *loadingProgressView;


@property(nonatomic,strong) KFCStampsModel *stampsModel;

@property(nonatomic,strong) UIButton *tipsButton;

@end
