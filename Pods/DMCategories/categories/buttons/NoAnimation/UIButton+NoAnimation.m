//
//  UIButton+NoAnimation.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 13.04.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "UIButton+NoAnimation.h"

@implementation UIButton (NoAnimation)

- (void)setTitle:(NSString *)title forStateWithoutAnimation:(UIControlState)state {
    [UIView setAnimationsEnabled:NO];
    
    [self setTitle:title forState:state];
    [self layoutIfNeeded];
    
    [UIView setAnimationsEnabled:YES];
}

@end
