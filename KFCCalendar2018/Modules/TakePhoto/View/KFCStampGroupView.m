//
//  KFCStampGroupView.m
//  肯德基
//
//  Created by 二哥 on 2017/11/1.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCStampGroupView.h"
#import "KFCPasterTableViewCell.h"
#import "KFCConfig.h"
#import "KFCStampGroupModel.h"
#import "KFCTipsView.h"
#import "AppDelegate.h"
#import "KFCTaskKeyModel.h"

@interface KFCStampGroupView () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIButton *preBtn;

@property(nonatomic, strong) KFCTipsView *tipsView;

@end

@implementation KFCStampGroupView

- (void)awakeFromNib {

    [super awakeFromNib];

    self.tableView.backgroundColor = KFC_COLOR_LIGHT_YELLOW;

    UIColor *customColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];

    self.tableBgView.layer.shadowColor = customColor.CGColor;
    self.tableBgView.layer.shadowOffset = CGSizeMake(-1, 1);    //shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    self.tableBgView.layer.shadowOpacity = 1.0;    //阴影透明度，默认0
    self.tableBgView.layer.shadowRadius = 2;        //阴影半径，默认3

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 40)];

    [self.tableView registerNib:[UINib nibWithNibName:KFCPasterTableViewCellReusedId bundle:nil] forCellReuseIdentifier:KFCPasterTableViewCellReusedId];

    [self bringSubviewToFront:self.coverView];
}

- (void)setData:(NSArray *)data {

    _data = data;

    NSMutableArray *titleArray = [NSMutableArray array];

    for (KFCStampGroupModel *stampGroupModel in data) {

        [titleArray addObject:stampGroupModel.name];
    }

    [self setupTagsButtonWithTitles:titleArray];

    for (int i = 1; i <= 12; i++) {
        NSString *imgNameStr = [NSString stringWithFormat:@"graphics-%zd", i];
        [self.localImageArray addObject:imgNameStr];
    }

}


- (void)setupTagsButtonWithTitles:(NSArray *)titleArray {

    for (int i = 0; i < titleArray.count; i++) {

        CGFloat btnW = 65 + 20;
        CGFloat btnH = 35;
        CGFloat btnX = SCREEN_WIDTH - 167;
        CGFloat btnY = 55 + i * (10 + btnH);

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        btn.tag = i;

        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setBackgroundColor:KFC_COLOR_LIGHT_YELLOW];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

        CGSize titleSize = [titleArray[i] sizeWithFont:[UIFont systemFontOfSize:12]];
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, (btnW - 13 - titleSize.width) / 2, 0, 0);

        btn.layer.cornerRadius = 3;
//        btn.layer.masksToBounds = YES;        // 这句不写, 可使view的圆角与阴影共存

        // shadow color
        UIColor *customColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];

        btn.layer.shadowColor = customColor.CGColor;
        btn.layer.shadowOffset = CGSizeMake(-1, 1);
        btn.layer.shadowOpacity = 1.0;
        btn.layer.shadowRadius = 2;

        [self addSubview:btn];

        //  isNew

        KFCStampGroupModel *stampGroupModel = self.data[i];
        if (stampGroupModel.isNew) {
            UIButton *newbtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX - 15, btnY - 15, 30, 30)];
            [newbtn setImage:[UIImage imageNamed:@"newTags"] forState:UIControlStateNormal];
            [self addSubview:newbtn];
        };

        [btn addTarget:self action:@selector(tagsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        UIColor *redcolor = [UIColor colorWithRed:(CGFloat) (216.0 / 256.0) green:(CGFloat) (48.0 / 256.0) blue:(CGFloat) (53.0 / 256.0) alpha:1.0f];

        UIColor *titleRedColor = [UIColor colorWithRed:(CGFloat) (222.0 / 256.0) green:0 blue:0 alpha:1.0f];
        // 暂时不可用
        if (!stampGroupModel.isAvailable) {

            UIColor *notAvailableColor = [UIColor colorWithRed:(CGFloat) (222.0 / 256.0) green:0 blue:0 alpha:0.3f];
            [btn setTitleColor:notAvailableColor forState:UIControlStateNormal];

            [btn addTarget:self action:@selector(tagsButtontouchDown:) forControlEvents:UIControlEventTouchDown];
            [btn addTarget:self action:@selector(tagsButtontouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        } else {
            [btn setTitleColor:titleRedColor forState:UIControlStateNormal];
        }
        // 最后一个  请期待
        if (i == titleArray.count - 1) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:redcolor];
            //            btn.enabled = NO;
        }

        // 默认选中第一个
        if (i == 0) {
            [self insertSubview:btn aboveSubview:self.tableBgView];
            self.preBtn = btn;
        } else {
            [self insertSubview:btn belowSubview:self.tableBgView];
        }
        [self.tableView reloadData];
    }

}

#pragma mark -  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 10;
//    if (self.preBtn.tag == 1 || self.preBtn.tag == 0) {
//    
//        return self.localImageArray.count;
//    }else{
    KFCStampGroupModel *pasterModel = self.data[(NSUInteger) self.preBtn.tag];
    return pasterModel.stamps.count;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    KFCPasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KFCPasterTableViewCellReusedId];
    NSArray *downloadedImageArr = [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_DOWN_LOADED_IAMGES];

    KFCStampGroupModel *pasterModel = self.data[(NSUInteger) self.preBtn.tag];
    NSArray *arr = [NSArray array];
    arr = [KFCStampsModel mj_objectArrayWithKeyValuesArray:pasterModel.stamps];
    KFCStampsModel *stampsModel = arr[(NSUInteger) indexPath.row];

    // 有taskkey 的图片, 在任何情况下都可以 点击 显示提示语

    // 如果pstaerModel.isAvailable = false 则所有的图片都变虚
    if (!pasterModel.isAvailable && !stampsModel.taskKey) {
        cell.coverImageView.alpha = 0.3f;
        cell.userInteractionEnabled = NO;
    } else {
        cell.coverImageView.alpha = 1.0f;
        cell.userInteractionEnabled = YES;
    }


    // 如果有 taskkey  就显示黄边
    if (stampsModel.taskKey) {
        cell.coverImageBgView.layer.borderColor = KFC_COLOR_HEXCOLOR(@"FFDD00").CGColor;
        cell.coverImageBgView.layer.borderWidth = 2;
    } else {
        cell.coverImageBgView.layer.borderWidth = 0;
    }


    /******     已完成任务的列表        ************/
    AppDelegate *myDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;

    NSMutableArray *completedTaskKeys = [NSMutableArray array];

    for (KFCTaskKeyModel *taskKeyModel in myDelegate.taskKeyArray) {
        if (taskKeyModel.completed) {
            [completedTaskKeys addObject:taskKeyModel.taskKey];
        }
    }

    if (![completedTaskKeys containsObject:stampsModel.taskKey] && stampsModel.taskKey) {

        // cell 上 加个按钮
        cell.tipsButton.tag = indexPath.row;

        [cell.tipsButton addTarget:self action:@selector(cellCoverButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [cell.tipsButton addTarget:self action:@selector(cellCoverButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [cell addSubview:cell.tipsButton];

    } else {
        if ([cell.subviews containsObject:cell.tipsButton]) {
            [cell.tipsButton removeFromSuperview];
        }
    }


    [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:stampsModel.thumb]];

    [cell.coverImageView setImageWithURL:[NSURL URLWithString:stampsModel.thumb] completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {

    }        usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    if ([downloadedImageArr containsObject:stampsModel.image]) { // 已下载  分为 已使用和未使用两种情况
        // 使用大图
        [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:stampsModel.image]];

        cell.userInteractionEnabled = YES;
    } else {      // 未下载  肯定是 未使用    未下载 稍微模糊一点
        cell.coverImageView.alpha = 0.5f;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // 开始下载大图
    NSArray *downloadedImageArr = [KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_DOWN_LOADED_IAMGES];

    KFCStampGroupModel *pasterModel = self.data[(NSUInteger) self.preBtn.tag];
    NSArray *arr = [NSArray array];
    arr = [KFCStampsModel mj_objectArrayWithKeyValuesArray:pasterModel.stamps];
    KFCStampsModel *stampsModel = arr[(NSUInteger) indexPath.row];

    if ([downloadedImageArr containsObject:stampsModel.image]) {     //  已下载   直接使用

        if ([self.delegate respondsToSelector:@selector(stampGroupViewDidClickedWithImageName:)]) {
            [self.delegate stampGroupViewDidClickedWithImageName:stampsModel.image];
        }

    } else {      // 未下载  去下载

        KFCPasterTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        // 带缓存的image download
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:stampsModel.image] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

            // 加个 下载中...  & 进度条
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.loadingProgressView.hidden = NO;
                cell.loadingTitleLabel.hidden = NO;
                CGFloat progress = (CGFloat) (receivedSize * 1.0 / expectedSize * 1.0);
                cell.loadingProgressView.progress = progress;
            });

        }                                         completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL *_Nullable imageURL) {

            if (finished) {
                cell.loadingProgressView.hidden = YES;
                cell.loadingTitleLabel.hidden = YES;
                cell.coverImageView.alpha = 1.0f;
                cell.coverImageView.image = image;

                //  本地 记一下  这个图片已下载
                NSMutableArray *downloadedImageArr = [[KFC_USER_DEFAULTS objectForKey:KFC_USER_DEFAULT_DOWN_LOADED_IAMGES] mutableCopy];
                if (!downloadedImageArr) {
                    downloadedImageArr = [NSMutableArray array];
                }
                [downloadedImageArr addObject:stampsModel.image];
                [KFC_USER_DEFAULTS setObject:downloadedImageArr forKey:KFC_USER_DEFAULT_DOWN_LOADED_IAMGES];
                [KFC_USER_DEFAULTS synchronize];

//                    [tableView reloadData];
            }
        }];

        // 不带缓存的  image download
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:stampsModel.image] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *_Nullable targetURL) {

        }                                                   completed:^(UIImage *_Nullable image, NSData *_Nullable data, NSError *_Nullable error, BOOL finished) {

        }];

    }
//    }
}

- (IBAction)coverButtonClicked:(UIButton *)sender {

    [UIView animateWithDuration:0.3f animations:^{

        self.x = 145;
    }                completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

}

- (void)tagsButtonClicked:(UIButton *)btn {

    if (btn == self.preBtn || [btn.titleLabel.text isEqualToString:@"敬请期待"]) return;

    KFCStampGroupModel *pasterModel = self.data[btn.tag];

    [self insertSubview:self.preBtn belowSubview:self.tableBgView];
    [self insertSubview:btn aboveSubview:self.tableBgView];

    if (btn.tag == 0) {

        if (self.localImageArray.count) [self.localImageArray removeAllObjects];

        for (int i = 1; i <= 12; i++) {
            NSString *imgNameStr = [NSString stringWithFormat:@"graphics-%zd", i];
            [self.localImageArray addObject:imgNameStr];
        }

    } else if (btn.tag == 1) {

        if (self.localImageArray.count) [self.localImageArray removeAllObjects];

        for (int i = 1; i <= 12; i++) {
            NSString *imgNameStr = [NSString stringWithFormat:@"calendar-%zd", i];
            [self.localImageArray addObject:imgNameStr];
        }

    } else {

    }

    self.preBtn = btn;

    [self.tableView reloadData];

}

- (void)tagsButtontouchDown:(UIButton *)sender {

    KFCStampGroupModel *pasterModel = self.data[sender.tag];
    if (pasterModel.isAvailable) return;

//        pasterModel.note = @"2018年2月1日贴纸可用，肯德基宅急送用户更有机会获得限量版黄金贴纸哦！";

    if (!pasterModel.note || [pasterModel.note isEqualToString:@""]) return;

    CGFloat tipsViewH = [self rectWithString:pasterModel.note].size.height + 14;

    CGRect tipsRect = CGRectMake(sender.x - 168, sender.y + 8, 165, tipsViewH);

    [self addTipsViewWithFrame:tipsRect noteString:pasterModel.note];

}

- (void)tagsButtontouchUp:(UIButton *)sender {

    [self removTipsView];
}

// cell  按下
- (void)cellCoverButtonTouchDown:(UIButton *)sender {

    // 加个判断, 不然会崩溃
//    if (sender.tag == 1 || sender.tag == 1) return;

    KFCStampGroupModel *pasterModel = self.data[self.preBtn.tag];
    NSArray *arr = [NSArray array];
    arr = [KFCStampsModel mj_objectArrayWithKeyValuesArray:pasterModel.stamps];
    KFCStampsModel *stampsModel = arr[sender.tag];

//    stampsModel.note = @"2018年2月1日贴纸可用，肯德基宅急送用户更有机会获得限量版黄金贴纸哦！";
    if (!stampsModel.note || [stampsModel.note isEqualToString:@""]) return;

    CGFloat tipsViewH = [self rectWithString:stampsModel.note].size.height + 14;

    CGRect tipsRect = CGRectMake(SCREEN_WIDTH - 165 - 85, sender.tag * 100 + 60, 165, tipsViewH);

    [self addTipsViewWithFrame:tipsRect noteString:stampsModel.note];
}

// cell 抬起
- (void)cellCoverButtonTouchUp:(UIButton *)sender {

    [self removTipsView];
//    [self.cellCoverButton removeFromSuperview];
}

// 开始添加 tipsview
- (void)addTipsViewWithFrame:(CGRect)frame noteString:(NSString *)noteStr {

    self.tipsView = [[KFCTipsView alloc] initWithFrame:frame];

    self.tipsView.titleStr = noteStr;
    self.tipsView.alpha = 0.0f;

    [self addSubview:self.tipsView];

    [UIView animateWithDuration:0.2f animations:^{
        self.tipsView.alpha = 1.0f;
    }];
}

// 移除掉 tipsview
- (void)removTipsView {

    [UIView animateWithDuration:0.2f animations:^{
        self.tipsView.alpha = 0.0f;
    }                completion:^(BOOL finished) {
        [self.tipsView removeFromSuperview];
    }];
}

- (CGRect)rectWithString:(NSString *)str {

    if (!str || [str isEqualToString:@""]) return CGRectZero;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 5;
    style.alignment = NSTextAlignmentLeft;

    NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: UIColor.redColor,
            NSParagraphStyleAttributeName: style
    };

    [attributedString addAttributes:textFontAttributes range:NSMakeRange(0, str.length)];

    CGRect titleRect = [attributedString boundingRectWithSize:CGSizeMake(165 - 20, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

//    NSLog(@"titleRect.size.height  ==  %.2f", titleRect.size.height);

    return titleRect;
}

- (NSMutableArray *)localImageArray {

    if (!_localImageArray) {
        _localImageArray = [NSMutableArray array];
    }
    return _localImageArray;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code





}


@end
