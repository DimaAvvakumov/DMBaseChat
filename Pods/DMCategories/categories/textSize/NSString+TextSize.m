//
//  NSString+TextSize.m
//  DMCategories
//
//  Created by Dima Avvakumov on 24.09.13.
//  Copyright (c) 2013 Dima Avvakumov. All rights reserved.
//

#import "NSString+TextSize.h"

@implementation NSString (TextSize)

- (CGSize) textSizeWithFont: (UIFont *) font {
    return [self textSizeWithFont:font size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0];
}

- (CGSize) textSizeWithFont: (UIFont *) font width: (CGFloat) width inSingleLine: (BOOL) singleLine {
    NSStringDrawingOptions options = 0;
    if (!singleLine) {
        options |= NSStringDrawingUsesLineFragmentOrigin;
    }
    
    return [self textSizeWithFont:font size:CGSizeMake(width, CGFLOAT_MAX) options:options];
}


- (CGSize) textSizeWithFont: (UIFont *) font size: (CGSize) size options: (NSStringDrawingOptions) options {
    NSDictionary *attr = @{NSFontAttributeName: font};
    
    CGRect rect = [self boundingRectWithSize:size options:options attributes:attr context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

@end
