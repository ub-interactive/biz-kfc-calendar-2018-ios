//
//  KFCTipsView.m
//  肯德基
//
//  Created by Apple on 2017/11/14.
//  Copyright © 2017年 汤旭浩. All rights reserved.
//

#import "KFCTipsView.h"
#import "KFCConfig.h"

@implementation KFCTipsView


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (self) {


        self.backgroundColor = [UIColor clearColor];


    }

    return self;
}

- (void)setTitleStr:(NSString *)titleStr {

    _titleStr = titleStr;

    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {

    // Drawing code

    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //  大的background
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.width - 5, self.height) cornerRadius:3];
    [UIColor.whiteColor setFill];
    [rectanglePath fill];

    // 小 三角
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(self.width - 5, 5)];
    [bezierPath addLineToPoint:CGPointMake(self.width, 10)];
    [bezierPath addLineToPoint:CGPointMake(self.width - 5, 15)];
    [UIColor.whiteColor setFill];
    [bezierPath fill];

    // 中间的文字
    CGRect textRect = CGRectMake(10, 7, self.width - 20, self.height - 14);
    {
        CGContextSaveGState(context);
        CGContextClipToRect(context, textRect);

        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineSpacing = 5;
        style.alignment = NSTextAlignmentLeft;
        NSDictionary *textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12],
                NSForegroundColorAttributeName: UIColor.redColor,
                NSParagraphStyleAttributeName: style
        };

        [self.titleStr drawInRect:CGRectMake(10, 7, self.width - 20, (self.height - 14)) withAttributes:textFontAttributes];
        CGContextRestoreGState(context);
    }

    // 加个 阴影
    UIColor *customColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    self.layer.shadowColor = customColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(1, 1);    //shadowOffset阴影偏移
    self.layer.shadowOpacity = 1.0;    //阴影透明度，默认0
    self.layer.shadowRadius = 2;        //阴影半径，默认3

}


@end
