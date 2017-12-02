//
//  KFCPasterView.h
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFCEditImageView.h"

//typedef enum : NSUInteger {
//    imgNameTypeUrl,
//    imgNameTypeString,
//} imgNameType;

@protocol KFCPasterViewButtonClickDelegate <NSObject>

//-(void)tableviewCell:(UITableViewCell *)cell pasterViewCellLongPressedCallback:(UITapGestureRecognizer *)sender imageName:(NSString *)imgName type:(imgNameType)type;

-(void)pasterViewDidClickedWithImageName:(NSString *)imgName;

-(void)pasterViewButtonClicked:(NSInteger)buttonTag;


@end


@interface KFCPasterView : UIView

@property (weak, nonatomic) IBOutlet UIButton *coverButton;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UIView *tableBgView;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSArray *data;

@property(nonatomic,weak) id<KFCPasterViewButtonClickDelegate> delegate;

@property(nonatomic,strong) KFCEditImageView *editImageview;

@property(nonatomic,strong) NSMutableArray *localImageArray;


@end
