//
//  QRView.h
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/25.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRMenu.h"
#import "JXQRButton.h"

@protocol QRViewDelegate <NSObject>

- (void)scanTypeConfig:(QRItem *)item;

@end


@interface QRView : UIView <UITextFieldDelegate>

@property(nonatomic, strong) UITextField *inputTextField;
@property(nonatomic, strong) JXQRButton *backQRButton;
@property(nonatomic, strong) JXQRButton *sureButton;

@property(nonatomic, strong) UIButton *scanImageButton;
@property(nonatomic, strong) UIButton *scanObjectButton;

/*
    任务列表按钮
 */
@property(nonatomic, strong) UIButton *missionButton;

@property(nonatomic, copy) void (^qrViewSureButtonClickedBlock)(NSString *codeStr);

@property(nonatomic, copy) void (^qrViewInputButtonClickedBlock)(BOOL isInput);

@property(nonatomic, weak) id <QRViewDelegate> delegate;
/**
 *  透明的区域
 */
@property(nonatomic, assign) CGSize transparentArea;

@property(nonatomic, strong) NSTimer *animateTimer;

@property(nonatomic, copy) void (^qrViewScanButtonClickedBlock)(NSInteger tag);

@end
