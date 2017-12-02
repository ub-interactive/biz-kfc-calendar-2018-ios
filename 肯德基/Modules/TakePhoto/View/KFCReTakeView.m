//
//  KFCReTakeView.m
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCReTakeView.h"
#import "KFCConfig.h"

@implementation KFCReTakeView


- (void)awakeFromNib {

    [super awakeFromNib];


}


- (IBAction)ButtonClicked:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(retakeViewButtonClicked:)]) {
        [self.delegate retakeViewButtonClicked:sender.tag];
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
