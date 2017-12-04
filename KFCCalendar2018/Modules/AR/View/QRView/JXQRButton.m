//
//  JXQRButton.m
//  HongDian
//
//  Created by 单于 on 2017/5/18.
//  Copyright © 2017年 BJ HL. All rights reserved.
//

#import "JXQRButton.h"


@implementation JXQRButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {

    return CGRectMake(20, 12.5, 20, 15);
}


- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor *color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];

    //// Rectangle Drawing    width = 100  height = 40
    CGRect rectangleRect = rect;
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRoundedRect:rectangleRect cornerRadius:20];
    [color setFill];
    [rectanglePath fill];
    {
        NSString *textContent = self.titleLabel.text;
        NSMutableParagraphStyle *rectangleStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        rectangleStyle.alignment = NSTextAlignmentCenter;

        NSDictionary *rectangleFontAttributes = @{NSFontAttributeName: self.titleLabel.font, NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: rectangleStyle};

        CGFloat rectangleTextHeight = [textContent boundingRectWithSize:CGSizeMake(rectangleRect.size.width, INFINITY) options:NSStringDrawingUsesLineFragmentOrigin attributes:rectangleFontAttributes context:nil].size.height;
        CGContextSaveGState(context);
        CGContextClipToRect(context, rectangleRect);

        if (!self.imageView.image) {
            [textContent drawInRect:CGRectMake(CGRectGetMinX(rectangleRect), CGRectGetMinY(rectangleRect) + (CGRectGetHeight(rectangleRect) - rectangleTextHeight) / 2, CGRectGetWidth(rectangleRect), rectangleTextHeight) withAttributes:rectangleFontAttributes];
        } else {
            [textContent drawInRect:CGRectMake(45, 13, 55, 20) withAttributes:rectangleFontAttributes];
        }
        CGContextRestoreGState(context);
    }


}


@end
