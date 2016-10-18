//
//  UIView+DMAnimation.h
//  DMCategories
//
//  Created by Dmitry Avvakumov on 17.11.14.
//  Copyright (c) 2014 Dima Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DMAnimation)

- (void) dm_setAlpha: (CGFloat) alpha animated: (BOOL) animated;
- (void) dm_setAlpha: (CGFloat) alpha animated: (BOOL) animated completion:(void(^)(BOOL finished))completionBlock;

@end
