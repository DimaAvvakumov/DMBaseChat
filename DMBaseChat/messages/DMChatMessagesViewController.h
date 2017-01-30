//
//  DMChatMessagesViewController.h
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMChatMessagesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILabel *textViewPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomToKeyboardConstraint;

#pragma mark - Settings

- (BOOL)pagingIsEnabled;
- (NSUInteger)pagingPerpage;

#pragma mark - Data access

- (NSUInteger)allItemsCount;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Access methods

- (NSString *)modelKeyAtIndexPath:(NSIndexPath *)indexPath;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - TextField

- (void)updateNewMessageText:(NSString *)text;
- (void)updateNewMessageText:(NSString *)text animated:(BOOL)animated;

#pragma mark - Actions

- (IBAction)sendMessageAction:(id)sender;

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;


@end
