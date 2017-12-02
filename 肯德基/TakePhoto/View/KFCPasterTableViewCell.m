//
//  KFCPasterTableViewCell.m
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCPasterTableViewCell.h"
#import "KFCConfig.h"

@implementation KFCPasterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.coverImageView.layer.cornerRadius = 3;
//    self.coverImageView.layer.masksToBounds = YES;
    
//    self.usedIcon.hidden = YES;
//    self.usedBgView.hidden = YES;
    
    self.loadingTitleLabel.hidden = YES;
    self.loadingProgressView.hidden = YES;
    self.loadingProgressView.transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    self.loadingProgressView.layer.cornerRadius = 4;
    self.loadingProgressView.layer.masksToBounds = YES;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTapImage:)];
    
//    [self addGestureRecognizer:tap];
    
}

-(void)prepareForReuse{

    [super prepareForReuse];
    
//    self.loadingTitleLabel.hidden = YES;
//    self.loadingProgressView.hidden = YES;
    
}

-(void)handelTapImage:(UITapGestureRecognizer *)sender{

//    if (self.cellLongPressedBlock) {
//        self.cellLongPressedBlock(sender);
//    }
}


-(UIButton *)tipsButton{

    if (!_tipsButton) {
        _tipsButton = [[UIButton alloc] initWithFrame:self.bounds];
        _tipsButton.backgroundColor = [UIColor clearColor];
    }
    return _tipsButton;
}


@end
