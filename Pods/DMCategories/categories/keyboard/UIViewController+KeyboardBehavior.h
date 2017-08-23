//
//  UIViewController+KeyboardBehavior.h
//  DMCategories
//
//  Created by Avvakumov Dmitry on 20.01.16.
//  Copyright © 2016 East Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMKeyboardManager.h"

@interface UIViewController (KeyboardBehavior)

@property (nonatomic, readonly) BOOL kb_isKeyboardPresented;
@property (nonatomic, readonly) CGFloat kb_keyboardHeight;

- (BOOL)kb_shouldKeyboardObserve;

- (void)kb_keyboardWillShowOrHideWithHeight:(CGFloat)height
                          animationDuration:(NSTimeInterval)animationDuration
                             animationCurve:(UIViewAnimationCurve)animationCurve;

- (void)kb_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve;

- (void)kb_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height;

- (DMKeyboardManager *)kb_keyboardManager;
- (BOOL)kb_shouldPresentHideButton;
- (CGFloat)kb_hideButtonOffset;

- (void)kb_hideKeyboard;

@end
