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

    self.tipView.layer.cornerRadius = 3;
    self.tipView.layer.masksToBounds = YES;

    self.tipView.hidden = YES;
    self.imageView.hidden = YES;

    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingIndicator.frame = CGRectMake(SCREEN_WIDTH / 2 - 50, SCREEN_HEIGHT / 2 - 50, 100, 100);

    [self.loadingIndicator startAnimating];
    [self addSubview:self.loadingIndicator];


}


@end
