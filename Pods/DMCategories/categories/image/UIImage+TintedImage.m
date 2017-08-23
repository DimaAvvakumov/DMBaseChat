//
//  UIImage+TintedImage.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 19.07.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "UIImage+TintedImage.h"

@implementation UIImage (TintedImage)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    UIImage *image = self;
    UIImage *newImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, newImage.scale);
    [tintColor set];
    [newImage drawInRect:CGRectMake(0, 0, image.size.width, newImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
