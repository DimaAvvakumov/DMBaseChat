//
//  UIColor+DMInterpolate.h
//  DMCategories
//
//  Created by Dmitry Avvakumov on 15.06.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DMInterpolate)

+ (UIColor *)dm_colorInterpolationFromColor:(UIColor *)start toColor:(UIColor *)end withFraction:(float)fraction;

@end
