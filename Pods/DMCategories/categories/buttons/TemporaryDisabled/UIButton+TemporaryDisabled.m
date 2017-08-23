//
//  UIButton+TemporaryDisabled.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 14.04.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "UIButton+TemporaryDisabled.h"

@implementation UIButton (TemporaryDisabled)

- (void)dm_disableForFewTimeInterval {
    [self dm_disableForDuration:0.4];
}

- (void)dm_disableForDuration:(NSTimeInterval)duration {
    self.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.enabled = YES;
    });
}

@end
