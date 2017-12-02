//
//  KFCScanSuccessView.m
//  肯德基
//
//  Created by Apple on 2017/11/16.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCScanSuccessView.h"
#import "KFCConfig.h"

@implementation KFCScanSuccessView

- (void)awakeFromNib {

    [super awakeFromNib];

    self.scanSuccessTipsView.layer.cornerRadius = 3;
    self.scanSuccessTipsView.layer.masksToBounds = YES;

    self.scanSuccessTipsView.hidden = YES;
    self.scanSuccessImageView.hidden = YES;

    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.frame = CGRectMake(SCREEN_WIDTH / 2 - 50, SCREEN_HEIGHT / 2 - 50, 100, 100);

    [self.indicator startAnimating];
    [self addSubview:self.indicator];


}


@end
