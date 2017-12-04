//
//  KFCRetakeView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFCRetakeViewButtonClickDelegate <NSObject>

- (void)retakeViewButtonClicked:(NSInteger)buttonTag;

@end

@interface KFCRetakeView : UIView

@property(weak, nonatomic) IBOutlet UIButton *pasterButton;

@property(nonatomic, weak) IBOutlet UIButton *retakeButton;

@property(nonatomic, weak) IBOutlet UIButton *saveButton;

@property(nonatomic, weak) id <KFCRetakeViewButtonClickDelegate> delegate;


@end
