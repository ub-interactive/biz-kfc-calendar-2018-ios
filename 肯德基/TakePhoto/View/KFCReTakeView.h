//
//  KFCReTakeView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFCReTakeViewButtonClickDelegate <NSObject>

-(void)reTakeViewButtonClicked:(NSInteger)buttonTag;

@end

@interface KFCReTakeView : UIView


@property (weak, nonatomic) IBOutlet UIButton *pasterButton;

//@property (weak, nonatomic) IBOutlet UIView *retakeBgView;

@property(nonatomic,weak) IBOutlet UIButton *retakeButton;

//@property (weak, nonatomic) IBOutlet UIView *saveBgView;
@property(nonatomic,weak) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIImageView *secondStepImageView;

@property(nonatomic,weak) id<KFCReTakeViewButtonClickDelegate> delegate;


@end
