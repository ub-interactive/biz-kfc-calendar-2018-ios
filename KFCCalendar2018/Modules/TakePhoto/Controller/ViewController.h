//
//  ViewController.h
//  肯德基
//
//  Created by 二哥 on 2017/10/31.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(weak, nonatomic) IBOutlet UIButton *scanButton;

@property(nonatomic, weak) IBOutlet UIButton *takePhotoButton;

@property(nonatomic, weak) IBOutlet UIButton *switchCameraButton;

@property(nonatomic, weak) IBOutlet UIButton *importFromAlbumButton;

@property(nonatomic, strong) NSMutableArray *stampGroups;

@end

