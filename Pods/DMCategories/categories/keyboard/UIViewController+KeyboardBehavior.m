//
//  UIViewController+KeyboardBehavior.m
//  DMCategories
//
//  Created by Avvakumov Dmitry on 20.01.16.
//  Copyright © 2016 East Media Ltd. All rights reserved.
//

#import "UIViewController+KeyboardBehavior.h"

#import <objc/runtime.h>

@interface UIViewController ()

@property (strong, nonatomic) UIButton *kb_hideButton;

@property (assign, nonatomic) BOOL kb_keyboardObserved;

@end

@implementation UIViewController (KeyboardBehavior)

#pragma mark - Properties hideButton

- (UIButton *)kb_hideButton {
    return objc_getAssociatedObject(self, @selector(kb_hideButton));
}

- (void)setKb_hideButton:(UIButton *)kb_hideButton {
    objc_setAssociatedObject(self, @selector(kb_hideButton), kb_hideButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Properties isKeyboardPresented

- (BOOL)kb_isKeyboardPresented {
    return [self kb_keyboardHeight] > 0.0;
}

- (CGFloat)kb_keyboardHeight {
    return [self.kb_keyboardManager keyboardHeight];
}

#pragma mark - Properties isKeyboardPresented

- (BOOL)kb_keyboardObserved {
    NSNumber *val = objc_getAssociatedObject(self, @selector(kb_keyboardObserved));
    return val.boolValue;
}

- (void)setKb_keyboardObserved:(BOOL)kb_keyboardObserved {
    objc_setAssociatedObject(self, @selector(kb_keyboardObserved), @(kb_keyboardObserved), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Swizzling

static void keyboardBehavior_swizzleInstanceMethod(Class c, SEL original, SEL replacement) {
    Method a = class_getInstanceMethod(c, original);
    Method b = class_getInstanceMethod(c, replacement);
    if (class_addMethod(c, original, method_getImplementation(b), method_getTypeEncoding(b))) {
        class_replaceMethod(c, replacement, method_getImplementation(a), method_getTypeEncoding(a));
    } else {
        method_exchangeImplementations(a, b);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        keyboardBehavior_swizzleInstanceMethod(class, @selector(viewWillAppear:), @selector(keyboardBehavior_viewWillAppear:));
        keyboardBehavior_swizzleInstanceMethod(class, @selector(viewWillDisappear:), @selector(keyboardBehavior_viewWillDisappear:));
        keyboardBehavior_swizzleInstanceMethod(class, @selector(viewDidDisappear:), @selector(keyboardBehavior_viewDidDisappear:));

    });
}

- (void)keyboardBehavior_viewWillAppear:(BOOL)animated {
    [self keyboardBehavior_viewWillAppear:animated];
    
    [self keyboardBehavior_createHideButton];
    
    // check observing
    BOOL needObserving = [self kb_shouldKeyboardObserve];
    if (needObserving == NO) return;
    
    // start observing
    self.kb_keyboardObserved = YES;
    [self kb_startObservingKeyboardNotifications];
    
    [self keyboardBehavior_setHideButtonVisible:NO keyboardHeight:0.0];
}

- (void)keyboardBehavior_viewWillDisappear:(BOOL)animated {
    [self keyboardBehavior_viewWillDisappear:animated];
    
    // pause observing
    self.kb_keyboardObserved = NO;
}

- (void)keyboardBehavior_viewDidDisappear:(BOOL)animated {
    [self keyboardBehavior_viewDidDisappear:animated];

    // check observing
    BOOL needObserving = [self kb_shouldKeyboardObserve];
    if (needObserving == NO) return;
    
    // stop observing
    [self kb_stopObservingKeyboardNotifications];
}

- (void)keyboardBehavior_createHideButton {
    if (![self kb_shouldPresentHideButton]) return;
    
    /* manager */
    DMKeyboardManager *kbManager = [self kb_keyboardManager];
    
    UIButton *hideButton = self.kb_hideButton;
    if (hideButton) return;
    
    /* create button */
    hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideButton.frame = CGRectMake(0.0, 0.0, 100.0, 40.0);
    hideButton.hidden = YES;
    [hideButton addTarget:self action:@selector(kb_hideKeyboardTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    /* image */
    NSString *title = kbManager.keyboardTitle;
    UIImage *image = kbManager.keyboardImage;
    if (image) {
        [hideButton setImage:image forState:UIControlStateNormal];
        
        /* update frame */
        CGRect frame = hideButton.frame;
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
        [hideButton setFrame:frame];
    }
    if (title) {
        [hideButton setTitle:title forState:UIControlStateNormal];
    }
    
    /* update frame */
    CGRect frame = hideButton.frame;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    frame.origin.y = self.view.bounds.size.height;
    hideButton.frame = frame;
    
    /* append */
    [self.view addSubview:hideButton];
    
    self.kb_hideButton = hideButton;
}

- (void)keyboardBehavior_setHideButtonVisible:(BOOL)visible keyboardHeight:(CGFloat)keyboardHeight {
    UIButton *hideButton = self.kb_hideButton;
    if (hideButton == nil) return;
    
    /* button offset */
    CGFloat offset = [self kb_hideButtonOffset];
    
    CGRect frame = hideButton.frame;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    frame.origin.y = self.view.bounds.size.height - keyboardHeight - frame.size.height - offset;
    hideButton.frame = frame;
    
    hideButton.hidden = !visible;
}

#pragma mark - Control methods

- (BOOL)kb_shouldKeyboardObserve {
    return NO;
}

- (void)kb_keyboardWillShowOrHideWithHeight:(CGFloat)height
                          animationDuration:(NSTimeInterval)animationDuration
                             animationCurve:(UIViewAnimationCurve)animationCurve {
    // override me if needed
}

- (void)kb_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve {
    // override me if needed
}

- (void)kb_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height {
    // override me if needed
}

- (DMKeyboardManager *)kb_keyboardManager {
    return [DMKeyboardManager sharedInstance];
}

- (BOOL)kb_shouldPresentHideButton {
    return NO;
}

- (CGFloat)kb_hideButtonOffset {
    return 0.0;
}

- (void)kb_hideKeyboardTapped:(UIButton *)sender {
    [self kb_hideKeyboard];
}

#pragma mark - Implementation methods

- (void)kb_startObservingKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kb_keyboardWillShowOrHideNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kb_keyboardWillShowOrHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)kb_stopObservingKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

}

#pragma mark - Private

- (void)kb_keyboardWillShowOrHideNotification:(NSNotification *)notification {
    if (!self.kb_keyboardObserved) return;
    
    NSDictionary *userInfo = notification.userInfo;
    
    // When keyboard is hiding, the height value from UIKeyboardFrameEndUserInfoKey sometimes is incorrect
    // Sets it manually to 0
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedRect = [self.view convertRect:keyboardFrame fromView:nil];
    BOOL isShowNotification = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    CGFloat keyboardHeight = isShowNotification ? CGRectGetHeight(convertedRect) : 0.0;
    
    // application state
    UIApplicationState state =  [[UIApplication sharedApplication] applicationState];
    if (state != UIApplicationStateActive && keyboardHeight != 0.0) return;
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [self kb_keyboardWillShowOrHideWithHeight:keyboardHeight
                            animationDuration:animationDuration
                               animationCurve:animationCurve];
    
    [UIView beginAnimations:@"UIViewController+KeyboardBehavior-Animation" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(kb_keyboardAnimationDidStop:finished:context:)];
    
    [self kb_keyboardShowOrHideAnimationWithHeight:keyboardHeight
                                 animationDuration:animationDuration
                                    animationCurve:animationCurve];
    
    [self keyboardBehavior_setHideButtonVisible:isShowNotification keyboardHeight:keyboardHeight];
    
    [UIView commitAnimations];
    
    BOOL isHideNotification = !isShowNotification;
    if (isHideNotification) {
        [self kb_hideKeyboard];
    }
}

- (void)kb_keyboardAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    CGFloat keyboardHeight = [self kb_keyboardHeight];
    [self kb_keyboardShowOrHideAnimationDidFinishedWithHeight:keyboardHeight];
}

- (void)kb_hideKeyboard {
    [self.kb_keyboardManager resignKeyboard];
}

@end
