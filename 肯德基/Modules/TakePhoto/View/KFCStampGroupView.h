//
//  KFCStampGroupView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFCEditImageView.h"

@protocol KFCShowStampGroupViewButtonClickDelegate <NSObject>

- (void)stampGroupViewDidClickedWithImageName:(NSString *)imgName;

@end


@interface KFCStampGroupView : UIView

@property(weak, nonatomic) IBOutlet UIButton *coverButton;

@property(weak, nonatomic) IBOutlet UIView *coverView;

@property(weak, nonatomic) IBOutlet UIView *tableBgView;


@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSArray *data;

@property(nonatomic, weak) id <KFCShowStampGroupViewButtonClickDelegate> delegate;

@property(nonatomic, strong) NSMutableArray *localImageArray;


@end
