//
//  KFCScanNagationView.m
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCScanNagationView.h"

@implementation KFCScanNagationView


- (void)awakeFromNib {

    [super awakeFromNib];

//    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];

//    self.backgroundColor = [UIColor redColor];


//    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
//    visualEffectView.frame = self.bounds;

//    [self addSubview:visualEffectView];



    self.closeButton.hidden = YES;
}

- (IBAction)backButtonClick:(id)sender {


}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
