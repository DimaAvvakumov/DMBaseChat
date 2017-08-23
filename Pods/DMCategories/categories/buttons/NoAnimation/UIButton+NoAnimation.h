//
//  UIButton+NoAnimation.h
//  DMCategories
//
//  Created by Dmitry Avvakumov on 13.04.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (NoAnimation)

- (void)setTitle:(NSString *)title forStateWithoutAnimation:(UIControlState)state;

@end
