//
//  KFCProgressHUD.m
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCProgressHUD.h"

@implementation KFCProgressHUD

+(void)showWithString:(NSString *)title inView:(UIView *)view{

    KFCProgressHUD *progress = [[NSBundle mainBundle] loadNibNamed:@"KFCProgressHUD" owner:self options:nil].lastObject;
    
    progress.frame = CGRectMake(0, 0, 180, 45);
    progress.center = view.center;
    
    progress.tipsLabel.text = title;
    
    progress.layer.cornerRadius = 3;
    progress.layer.masksToBounds = YES;
    
    progress.alpha = 0.0f;
    
    [view addSubview:progress];
    
    [UIView animateWithDuration:0.5f animations:^{
       
        progress.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                progress.alpha = 0;
            } completion:^(BOOL finished) {
                [progress removeFromSuperview];
            }];
        });
    }];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
