//
//  NSString+TextSize.h
//  DMCategories
//
//  Created by Dima Avvakumov on 24.09.13.
//  Copyright (c) 2013 Dima Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (TextSize)

- (CGSize) textSizeWithFont: (UIFont *) font;
- (CGSize) textSizeWithFont: (UIFont *) font width: (CGFloat) width inSingleLine: (BOOL) singleLine;

- (CGSize) textSizeWithFont: (UIFont *) font size: (CGSize) size options: (NSStringDrawingOptions) options;

@end
