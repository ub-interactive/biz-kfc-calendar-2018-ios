//
//  KFCOneMoreView.m
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCOneMoreView.h"
#import "KFCConfig.h"

@implementation KFCOneMoreView


- (void)awakeFromNib {
    [super awakeFromNib];
 
    self.oneMoreButton.layer.cornerRadius = 3;
    self.oneMoreButton.layer.masksToBounds = YES;
    
}

// 分享
- (IBAction)shareButtonClicked:(UIButton *)sender {
    
    

    
    
    
}

// 再拍一张  && share
- (IBAction)oneMoreButtonClicked:(UIButton *)sender {
    
    if (sender.tag == 10) {         // 分享  分享按钮的tag是10
        self.shareTipsImageView.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:KFC_USER_DEFAULT_FIRST_SHARE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([self.delegate respondsToSelector:@selector(oneMoreViewButtonClicked:)]) {
        
        [self.delegate oneMoreViewButtonClicked:sender];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
