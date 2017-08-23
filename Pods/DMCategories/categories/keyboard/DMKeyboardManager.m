//
//  DMKeyboardManager.m
//  Pods
//
//  Created by Dmitry Avvakumov on 07.03.17.
//
//

#import "DMKeyboardManager.h"

@interface DMKeyboardManager ()

@property (strong, nonatomic) NSMutableDictionary <NSString *, void(^)(UIResponder *newResponder)> *beginEditingEventsObservers;
@property (strong, nonatomic) NSMutableDictionary <NSString *, void(^)(CGFloat height, UIResponder *firstResponder)> *keyboardEventsObservers;

@end

@implementation DMKeyboardManager

#pragma mark - Shared instance

+ (DMKeyboardManager *) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.firstResponder = nil;
        [self startObservingDidBeginEditingNotification];
        [self startObservingKeyboardNotifications];
        
        self.beginEditingEventsObservers = [NSMutableDictionary dictionaryWithCapacity:10];
        self.keyboardEventsObservers = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (void)dealloc {
    [self stopObservingDidBeginEditingNotification];
    [self stopObservingKeyboardNotifications];
}

#pragma mark - Editing Notification

- (void)startObservingDidBeginEditingNotification {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidBeginEditing:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
}

- (void)stopObservingDidBeginEditingNotification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:nil];
}

#pragma mark - Keyboard Notification

- (void)startObservingKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHideNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowOrHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)stopObservingKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Input Notifications

- (void)textDidBeginEditing:(NSNotification *)notification {
    UIResponder *responder = notification.object;
    
    if (!responder) return;
    if (![responder isKindOfClass:[UIResponder class]]) return;
    
    self.firstResponder = responder;
    
    [self sendByObserversDidBeginEventWithResponder:responder];
}

- (void)keyboardWillShowOrHideNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;

    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    BOOL isShowNotification = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    CGFloat keyboardHeight = isShowNotification ? CGRectGetHeight(keyboardFrame) : 0.0;

    self.keyboardHeight = keyboardHeight;
    
    UIResponder *responder = self.firstResponder;
    if (keyboardHeight == 0.0) {
        self.firstResponder = nil;
    }
    
    [self sendByObserversKeyboardEventWithHeight:keyboardHeight firstResponder:responder];
}

#pragma mark - Resign

- (void)resignKeyboard {
    UIResponder *responder = self.firstResponder;
    if (responder == nil) return;
    
    if (responder.isFirstResponder) {
        [responder resignFirstResponder];
    } else {
        NSLog(@"is not First Responder");
    }
}

#pragma mark - Observing

- (void)addKeyboardObserver:(id)observer forBeginEditingEvent:(void(^)(UIResponder *newResponder))beginEventBlock {
    NSString *key = [NSString stringWithFormat:@"%p", observer];
    NSMutableDictionary *observers = self.beginEditingEventsObservers;
    
    [observers setObject:[beginEventBlock copy] forKey:key];
}

- (void)addKeyboardObserver:(id)observer forKeyboardEvent:(void(^)(CGFloat height, UIResponder *firstResponder))keyboardEventBlock {
    NSString *key = [NSString stringWithFormat:@"%p", observer];
    NSMutableDictionary *observers = self.keyboardEventsObservers;
    
    [observers setObject:[keyboardEventBlock copy] forKey:key];
}

- (void)removeKeyboardObserver:(id)observer {
    NSString *key = [NSString stringWithFormat:@"%p", observer];
    
    [self.beginEditingEventsObservers removeObjectForKey:key];
    [self.keyboardEventsObservers removeObjectForKey:key];
}

#pragma mark - Send events by observers

- (void)sendByObserversDidBeginEventWithResponder:(UIResponder *)responder {
    NSArray *allkeys = [self.beginEditingEventsObservers allKeys];
    for (NSString *key in allkeys) {
        void(^block)(UIResponder *newResponder) = [self.beginEditingEventsObservers objectForKey:key];
        
        if (block) {
            block( responder );
        }
    }
}

- (void)sendByObserversKeyboardEventWithHeight:(CGFloat)height firstResponder:(UIResponder *)firstResponder {
    NSArray *allkeys = [self.keyboardEventsObservers allKeys];
    for (NSString *key in allkeys) {
        void(^block)(CGFloat height, UIResponder *newResponder) = [self.keyboardEventsObservers objectForKey:key];
        
        if (block) {
            block( height, firstResponder );
        }
    }
}

@end
