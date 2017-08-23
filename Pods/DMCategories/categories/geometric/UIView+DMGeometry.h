//
//  UIView+DMGeometry.h
//  DMCategories
//
//  Created by Dmitry Avvakumov on 22.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DMGeometry)

#pragma mark - Origin
- (void)setFrameOriginX:(CGFloat)value;
- (void)setFrameOriginY:(CGFloat)value;

#pragma mark - Origin alignment
- (void)alignFrameRightToRightSuperview;
- (void)alignFrameRightToRightSuperviewWithOffset:(CGFloat)value;
- (void)alignFrameBottomToBottomSuperview;
- (void)alignFrameBottomToBottomSuperviewWithOffset:(CGFloat)value;

#pragma mark - Size
- (void)setFrameSize:(CGSize)size;
- (void)setFrameSizeWidth:(CGFloat)value;
- (void)setFrameSizeHeight:(CGFloat)value;

#pragma mark - Center
- (void)setCenterX:(CGFloat)value;
- (void)setCenterY:(CGFloat)value;


@end
