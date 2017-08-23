//
//  UIColor+DMInterpolate.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 15.06.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "UIColor+DMInterpolate.h"

@implementation UIColor (DMInterpolate)

+ (UIColor *)dm_colorInterpolationFromColor:(UIColor *)start toColor:(UIColor *)end withFraction:(float)fraction {
    /* check */
    if (fraction < 0.0) fraction = 0.0;
    if (fraction > 1.0) fraction = 1.0;
    
    /* optimize */
    if (fraction == 0.0) return start;
    if (fraction == 1.0) return end;
    
    size_t startNumComponents = CGColorGetNumberOfComponents(start.CGColor);
    const CGFloat *startComponents = CGColorGetComponents(start.CGColor);
    
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    if (startNumComponents == 4) {
        red = startComponents[0];
        green = startComponents[1];
        blue = startComponents[2];
        alpha = startComponents[3];
    } else if (startNumComponents == 2) {
        red = startComponents[0];
        green = startComponents[0];
        blue = startComponents[0];
        alpha = startComponents[1];
    }
    
    size_t endNumComponents = CGColorGetNumberOfComponents(end.CGColor);
    const CGFloat *endComponents = CGColorGetComponents(end.CGColor);
    
    CGFloat finalRed = 0.0;
    CGFloat finalGreen = 0.0;
    CGFloat finalBlue = 0.0;
    CGFloat finalAlpha = 0.0;
    
    if (endNumComponents == 4) {
        finalRed = endComponents[0];
        finalGreen = endComponents[1];
        finalBlue = endComponents[2];
        finalAlpha = endComponents[3];
    } else if (endNumComponents == 2) {
        finalRed = endComponents[0];
        finalGreen = endComponents[0];
        finalBlue = endComponents[0];
        finalAlpha = endComponents[1];
    }
    
    CGFloat newRed   = (1.0 - fraction) * red   + fraction * finalRed;
    CGFloat newGreen = (1.0 - fraction) * green + fraction * finalGreen;
    CGFloat newBlue  = (1.0 - fraction) * blue  + fraction * finalBlue;
    CGFloat newAlpha = (1.0 - fraction) * alpha + fraction * finalAlpha;
    
    return  [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@end
