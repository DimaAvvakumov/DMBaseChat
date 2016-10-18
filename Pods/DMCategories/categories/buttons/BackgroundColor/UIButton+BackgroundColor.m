//
//  UIButton+BackgroundColor.m
//  DMCategories
//
//  Created by Avvakumov Dmitry on 21.03.16.
//  Copyright © 2016 East Media Ltd. All rights reserved.
//

#import "UIButton+BackgroundColor.h"

@implementation UIButton (BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    
    UIImage *image = [self imageOfPixelImageWithCustomColor:color];
    [self setBackgroundImage:image forState:state];
    
}

#pragma mark Drawing Methods

- (void)drawPixelImageWithCustomColor: (UIColor*)customColor {
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 1, 1)];
    [customColor setFill];
    [rectanglePath fill];
}

#pragma mark Generated Images

- (UIImage*)imageOfPixelImageWithCustomColor: (UIColor*)customColor {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0f);
    [self drawPixelImageWithCustomColor: customColor];
    
    UIImage* imageOfPixelImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageOfPixelImage;
}

@end
