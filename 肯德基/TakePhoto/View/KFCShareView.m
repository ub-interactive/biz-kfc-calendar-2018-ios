//
//  KFCShareView.m
//  肯德基
//
//  Created by 二哥 on 2017/11/8.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCShareView.h"

@implementation KFCShareView


-(void)awakeFromNib{

    [super awakeFromNib];
    
    
    
    
    
    
    
    
}


- (IBAction)weichatFriendButtonClicked:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(shareViewButtonClicked:)]) {
        [self.delegate shareViewButtonClicked:sender];
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
