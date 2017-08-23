//
//  UIButton+TemporaryDisabled.h
//  DMCategories
//
//  Created by Dmitry Avvakumov on 14.04.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (TemporaryDisabled)

- (void)dm_disableForFewTimeInterval;
- (void)dm_disableForDuration:(NSTimeInterval)duration;

@end
