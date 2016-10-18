//
//  UIView+DMAnimation.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 17.11.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import "UIView+DMAnimation.h"

@implementation UIView (DMAnimation)

- (void) dm_setAlpha:(CGFloat)alpha animated:(BOOL)animated {
    [self dm_setAlpha:alpha animated:animated completion:nil];
}

- (void) dm_setAlpha: (CGFloat) alpha animated: (BOOL) animated completion:(void (^)(BOOL))completionBlock {
    
    __weak typeof (self) weakSelf = self;
    
    if (animated) {
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            weakSelf.alpha = alpha;
            
        } completion:^(BOOL finished) {
            if (completionBlock) {
                completionBlock(finished);
            }
        }];
        
    } else {
        weakSelf.alpha = alpha;
        
        if (completionBlock) {
            completionBlock(YES);
        }
    }
    
}

@end
