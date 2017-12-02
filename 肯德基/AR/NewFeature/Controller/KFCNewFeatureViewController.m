//
//  KFCNewFeatureViewController.m
//  肯德基
//
//  Created by 二哥 on 2017/11/26.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCNewFeatureViewController.h"
#import "KFCNewFeatureView.h"
#import "KFCConfig.h"
#import <AVFoundation/AVFoundation.h>

@interface KFCNewFeatureViewController ()<UIScrollViewDelegate>

//@property (nonatomic, retain) AVPlayer *videoPlayer;

@end

@implementation KFCNewFeatureViewController

-(void)viewDidLoad{

    [super viewDidLoad];
    
    self.newfeatureScrollView.contentSize = CGSizeMake(4 * SCREEN_WIDTH, 0);
    
    [self setScrollViewImages];
}

-(void)setScrollViewImages{
    
    for (int i = 0 ; i < 4; i++) {
        
        KFCNewFeatureView *newFeatureView = [[NSBundle mainBundle] loadNibNamed:@"KFCNewFeatureView" owner:self options:nil].lastObject;
        newFeatureView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        newFeatureView.pageControl.currentPage = i;
        
        newFeatureView.iconImageView.hidden = (i != 0);
        
        newFeatureView.nextPageButton.tag = i;
        [newFeatureView.nextPageButton addTarget:self action:@selector(newfeatureNextPageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [newFeatureView.skipButton addTarget:self action:@selector(newfeatureSkipButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSString *fileName = [NSString stringWithFormat:@"newfeatur%zd", i];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"m4v"];
        NSURL *sourceMovieURL = [NSURL fileURLWithPath:filePath];
        
        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        AVPlayer *videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:videoPlayer];
        
        playerLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH + 40, SCREEN_HEIGHT);
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [newFeatureView.layer addSublayer:playerLayer];
        [videoPlayer play];
        
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [KFC_NOTIFICATION_CENTER addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[videoPlayer currentItem]];
        
        if (i == 3) {       // 开始 按钮
            [newFeatureView.nextPageButton setImage:[UIImage imageNamed:@"newfeature_start"] forState:UIControlStateNormal];
        }
    }
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
    

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat page = scrollView.contentOffset.x / scrollView.width;
    NSInteger pageNum = (int)(page + 0.5);
//    if (self.jxnewFeaturePageControl.currentPage != pageNum) {
//        self.jxnewFeaturePageControl.currentPage = pageNum;
//    }
}



/**
 *   下一页  or  开始
 */
-(void)newfeatureNextPageButtonClicked:(UIButton *)sender{
    
    
    
    if (sender.tag == 3) {      // 开始 按钮
        
    }
    
    
}

/**
 *   跳过
 */

-(void)newfeatureSkipButtonClicked{

    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
