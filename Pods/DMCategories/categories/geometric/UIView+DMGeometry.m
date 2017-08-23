//
//  UIView+DMGeometry.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 22.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "UIView+DMGeometry.h"

@implementation UIView (DMGeometry)

#pragma mark - Origin

- (void)setFrameOriginX:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}

- (void)setFrameOriginY:(CGFloat)value {
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}

#pragma mark - Origin alignment

- (void)alignFrameRightToRightSuperview {
    [self alignFrameRightToRightSuperviewWithOffset:0.0];
}

- (void)alignFrameRightToRightSuperviewWithOffset:(CGFloat)value {
    CGRect frame = self.frame;
    CGRect superFrame = self.superview.frame;
    frame.origin.x = superFrame.size.width - frame.size.width + value;
    self.frame = frame;
}

- (void)alignFrameBottomToBottomSuperview {
    [self alignFrameBottomToBottomSuperviewWithOffset:0.0];
}

- (void)alignFrameBottomToBottomSuperviewWithOffset:(CGFloat)value {
    CGRect frame = self.frame;
    CGRect superFrame = self.superview.frame;
    frame.origin.y = superFrame.size.height - frame.size.height + value;
    self.frame = frame;
}

#pragma mark - Size

- (void)setFrameSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setFrameSizeWidth:(CGFloat)value {
    CGRect frame = self.frame;
    frame.size.width = value;
    self.frame = frame;
}

- (void)setFrameSizeHeight:(CGFloat)value {
    CGRect frame = self.frame;
    frame.size.height = value;
    self.frame = frame;
}

#pragma mark - Center

- (void)setCenterX:(CGFloat)value {
    CGPoint center = self.center;
    center.x = value;
    [self setCenter:center];
}

- (void)setCenterY:(CGFloat)value {
    CGPoint center = self.center;
    center.y = value;
    [self setCenter:center];
}

@end
