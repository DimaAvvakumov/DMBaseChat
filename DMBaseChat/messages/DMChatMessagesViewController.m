//
//  DMChatMessagesViewController.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "DMChatMessagesViewController.h"

// frameworks
#import <MagicalRecord/MagicalRecord.h>

// categories
#import <DMCategories/DMCategories.h>

// NSString *chatBaseCacheName = @"ChatBase";

@interface DMChatMessagesViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@property (assign, nonatomic) BOOL scrollToBottom;
@property (assign, nonatomic) BOOL observeDisable;

@property (assign, nonatomic) BOOL fixBottomSpace;
@property (assign, nonatomic) CGFloat bottomSpace;

@property (strong, nonatomic) NSMutableDictionary *estimatedHeights;

// fetching
@property (assign, nonatomic) NSUInteger fetchLimit;

@end

@implementation DMChatMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.estimatedHeights = [NSMutableDictionary dictionaryWithCapacity:10];
    self.scrollToBottom = YES;
    self.observeDisable = NO;
    self.fixBottomSpace = NO;
    self.bottomSpace = 0.0;
    self.pagingEnabled = YES;
    
    self.fetchLimit = 20.0;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeGesture:)];
    [self.tableView addGestureRecognizer:gr];
    
    // text view
    self.textView.scrollEnabled = NO;
    
    [self initFetchController];
    [self performFetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startObservingHeight];
    [self updateTextViewPlaceholderAnimated:NO];
    [self updateTextViewHeightAnimated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopObservingHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Method to overwrite

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = nil;
    // NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageEntity class])];
    
    // sort
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
    return fetchRequest;
}

- (NSString *)sectionKeyPath {
    return nil;
}

- (void)refreshRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Height observing

- (void)startObservingHeight {
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)stopObservingHeight {
    @try {
        [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    } @catch (NSException *exception) {
        NSLog(@"Observation exception: %@", exception);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"contentSize"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        if (self.observeDisable) return;
        
        [self updateTableScrollAppereance];
    }
}

- (void)updateTableScrollAppereance {
    if (self.scrollToBottom == YES) {
        [self scrollToBottomAnimated:YES];
    }
    if (self.fixBottomSpace == YES) {
        self.fixBottomSpace = NO;
        [self scrollToBottomSpace];
    }
}

#pragma mark - Fetch controller initialization

- (void)initFetchController {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    NSString *sectionKeyPath = [self sectionKeyPath];
    
    NSFetchedResultsController *fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:sectionKeyPath cacheName:nil];
    fetchController.delegate = self;
    
    self.fetchController = fetchController;
    
    [self initFetchPaging];
}

- (void)performFetch {
    NSError *error = nil;
    BOOL fetchResult = [self.fetchController performFetch:&error];
    if (fetchResult == NO) {
        NSLog(@"Fetch error: %@", error);
    }
}

- (void)initFetchPaging {
    if (!self.pagingEnabled) return;
    
    NSInteger count = [self allItemsCount];
    NSInteger expectable = self.fetchLimit;
    if (count > expectable) {
        self.fetchController.fetchRequest.fetchLimit = expectable;
        self.fetchController.fetchRequest.fetchOffset = count - expectable;
    }
}

- (void)expangFetch {
    if (!self.pagingEnabled) return;
    
    NSArray *fetchedObjects = [self.fetchController fetchedObjects];
    if (fetchedObjects == nil) return;
    
    NSInteger fetchedCount = [fetchedObjects count];
    
    NSInteger count = [self allItemsCount];
    NSInteger expectable = fetchedCount + self.fetchLimit;
    if (count > expectable) {
        self.fetchController.fetchRequest.fetchLimit = expectable;
        self.fetchController.fetchRequest.fetchOffset = count - expectable;
    }
    
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    
    self.fixBottomSpace = YES;
    self.bottomSpace = self.tableView.contentSize.height - self.tableView.frame.size.height - self.tableView.contentInset.bottom - self.tableView.contentOffset.y;
    
    [self.tableView reloadData];
}

#pragma mark - Data access

- (NSUInteger)allItemsCount {
    return 0;
}

#pragma mark - Signal methods

- (void)reloadFetchController {
    [self initFetchController];
    [self performFetch];
}

#pragma mark - Keyboard

- (BOOL)kb_shouldKeyboardObserve {
    return YES;
}

- (void)kb_keyboardShowOrHideAnimationWithHeight:(CGFloat)height animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve {
//    UIEdgeInsets insets = self.tableView.contentInset;
//    insets.bottom = height;
//    [self.tableView setContentInset:insets];
    
    [self tableViewInset];
    
    self.bottomToKeyboardConstraint.constant = height;
    if (height > 0 && self.scrollToBottom) {
        [self scrollToBottomAnimated:NO];
        
        self.observeDisable = YES;
    }
    
    [self.view layoutIfNeeded];
}

- (void)kb_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height {
    self.observeDisable = NO;
}

#pragma mark - Close keyboard

- (void)closeGesture:(UIGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) return;
    
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // scroll to bottom update
    if (scrollView.isDragging == YES) {
        CGFloat offset = self.tableView.contentOffset.y;
        UIEdgeInsets inset = self.tableView.contentInset;
        CGFloat tableH = self.tableView.frame.size.height;
        CGFloat contentHeight = self.tableView.contentSize.height;
        CGFloat minHeight = contentHeight - tableH - offset + inset.bottom;
        
        if (minHeight <= 0.0) {
            self.scrollToBottom = YES;
        } else {
            self.scrollToBottom = NO;
        }
    }
    
    // paging
    static BOOL appendAvaliable = YES;
    if (scrollView.isDragging == YES && appendAvaliable) {
        CGFloat offset = self.tableView.contentOffset.y;
        
        if (offset < 20.0) {
            appendAvaliable = NO;
            [self expangFetch];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                appendAvaliable = YES;
            });
        }
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGFloat tableH = self.tableView.frame.size.height;
    CGFloat h = self.tableView.contentSize.height;
    
    CGFloat offset = h - tableH + self.tableView.contentInset.bottom;
    if (offset > 0.0) {
        [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:animated];
    }
}

- (void)scrollToBottomSpace {
    CGFloat tableH = self.tableView.frame.size.height;
    CGFloat h = self.tableView.contentSize.height;
    
    CGFloat offset = h - tableH - self.tableView.contentInset.bottom - self.bottomSpace;
    if (offset > 0.0) {
        [self.tableView setContentOffset:CGPointMake(0.0, offset)];
        // [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:animated];
    }
    
    CGFloat space = self.tableView.contentSize.height - self.tableView.frame.size.height - self.tableView.contentInset.bottom - self.tableView.contentOffset.y;
    NSLog(@"Bottom relize: %f", space);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray <id<NSFetchedResultsSectionInfo>> *secitons = [self.fetchController sections];
    if (secitons == nil || [secitons count] == 0) return 0;
    
    return [secitons count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray <id<NSFetchedResultsSectionInfo>> *secitons = [self.fetchController sections];
    if (secitons == nil || [secitons count] == 0) return 0;
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [secitons objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Automaic height

- (NSString *)modelKeyAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    return key;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowAtIndexPath:indexPath];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
            [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
            [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeMove: {
            
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            
            break;
        }
        default:
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        }
        case NSFetchedResultsChangeMove: {
            if ([indexPath isEqual:newIndexPath]) {
                [self tryRefreshRowAtIndexPath:indexPath];
            } else {
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            }
            
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            // do nothing
            [self tryRefreshRowAtIndexPath:indexPath];
            
            break;
        }
        default:
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

- (void)tryRefreshRowAtIndexPath:(NSIndexPath *)indexPath {
    // check for visible
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    if (NO == [visibleRows containsObject:indexPath]) return;
    
    [self refreshRowAtIndexPath:indexPath];
    
}

#pragma mark - Access methods

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray <id<NSFetchedResultsSectionInfo>> *secitons = [self.fetchController sections];
    if (secitons == nil || [secitons count] == 0) return 0;
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [secitons objectAtIndex:section];
    return [sectionInfo.objects objectAtIndex:row];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateTextViewPlaceholderAnimated:YES];
    [self updateTextViewHeightAnimated:YES];
}

- (void)updateTextViewHeightAnimated:(BOOL)animated {
    UIEdgeInsets insets = self.textView.textContainerInset;
    CGFloat insetAppend = insets.top + insets.bottom;
    NSString *text = self.textView.text;
    UIFont *font = self.textView.font;
    CGFloat w = self.textView.frame.size.width;
    CGSize maxSize = CGSizeMake(w, CGFLOAT_MAX);
    CGSize textSize = CGSizeZero;
    if (text && text.length > 0) {
        textSize = [self textSize:text withFont:font size:maxSize options:NSStringDrawingUsesLineFragmentOrigin];
    }
    CGFloat newHeight = MAX(textSize.height + insetAppend, 36.0);
    if (newHeight > 100.0) {
        newHeight = 100.0;
    }
    
    self.textViewHeightConstraint.constant = newHeight;
    
    // correct table inset
    [self tableViewInset];
    
    // weak self
    __weak typeof (self) weakSelf = self;
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            typeof (weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) return ;
            
            [strongSelf.view layoutIfNeeded];
        } completion:nil];
        
    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)tableViewInset {
    CGFloat kh = self.kb_keyboardHeight;
    CGFloat tt = self.textViewHeightConstraint.constant + 16.0;
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = kh + tt;
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

- (void)updateTextViewPlaceholderAnimated:(BOOL)animated {
    NSString *text = self.textView.text;
    CGFloat alpha = (text && text.length > 0) ? 0.0 : 1.0;
    
    // weak self
    __weak typeof (self) weakSelf = self;
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            typeof (weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) return ;
            
            strongSelf.textViewPlaceholderLabel.alpha = alpha;
        } completion:nil];
    } else {
        self.textViewPlaceholderLabel.alpha = alpha;
    }
}

- (CGSize) textSize:(NSString *)text withFont: (UIFont *) font size: (CGSize) size options: (NSStringDrawingOptions) options {
    NSDictionary *attr = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:size options:options attributes:attr context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

#pragma mark - Append action

- (IBAction)sendMessageAction:(UIButton *)sender { }

@end
