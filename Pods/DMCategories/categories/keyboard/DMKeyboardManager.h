//
//  DMKeyboardManager.h
//  Pods
//
//  Created by Dmitry Avvakumov on 07.03.17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DMKeyboardManager : NSObject

#pragma mark - Shared instance
+ (DMKeyboardManager *) sharedInstance;

/* first responder */
@property (weak, nonatomic) UIResponder *firstResponder;

/* show / hide button */
@property (strong, nonatomic) UIImage *keyboardImage;
@property (strong, nonatomic) NSString *keyboardTitle;

/* height */
@property (assign, nonatomic) CGFloat keyboardHeight;

- (void)resignKeyboard;

#pragma mark - Observing
- (void)addKeyboardObserver:(id)observer forBeginEditingEvent:(void(^)(UIResponder *newResponder))beginEventBlock;
- (void)addKeyboardObserver:(id)observer forKeyboardEvent:(void(^)(CGFloat height, UIResponder *firstResponder))keyboardEventBlock;
- (void)removeKeyboardObserver:(id)observer;

@end
