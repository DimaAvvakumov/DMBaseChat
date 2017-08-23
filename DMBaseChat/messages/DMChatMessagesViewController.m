//
//  DMChatMessagesViewController.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "DMChatMessagesViewController.h"

// categories
#import <DMCategories/DMCategories.h>

// NSString *chatBaseCacheName = @"ChatBase";

#define DMChatMessagesViewController_ObjKey @"obj"
#define DMChatMessagesViewController_OffsetKey @"offset"

@interface DMChatMessagesViewController () <NSFetchedResultsControllerDelegate>

/* fetch controller */
@property (strong, nonatomic) NSFetchedResultsController *fetchController;

/* indicator for follow to bottom */
@property (assign, nonatomic) BOOL scrollToBottom;

/* Heights cache layer */
@property (strong, nonatomic) NSMutableDictionary *estimatedHeights;
@property (assign, nonatomic) CGFloat preferredWidth;

@property (strong, nonatomic) NSMutableArray *cellBottomSpaces;

// paging
@property (assign, nonatomic) BOOL pagingEnabled;

// fetching
@property (assign, nonatomic) NSUInteger fetchLimit;

// observing
@property (assign, nonatomic) BOOL isObservedHeight;

@end

@implementation DMChatMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.estimatedHeights = [NSMutableDictionary dictionaryWithCapacity:10];
    self.preferredWidth = 0.0;
    
    
    self.pagingEnabled = [self pagingIsEnabled];
    self.fetchLimit = [self pagingPerpage];
    
    /* bottom */
    self.cellBottomSpaces = [NSMutableArray arrayWithCapacity:10];
    
    self.isObservedHeight = NO;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeGesture:)];
    [self.tableView addGestureRecognizer:gr];
    
    // text view
    self.textView.delegate = self;
    
    [self initFetchController];
    [self performFetch];
    
    /* Scroll to bottom initially */
    self.scrollToBottom = YES;
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

- (void)dealloc {
    [self stopObservingHeight];
}

#pragma mark - Settings

- (BOOL)pagingIsEnabled {
    return YES;
}

- (NSUInteger)pagingPerpage {
    return 20.0;
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
    [self.textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    self.isObservedHeight = YES;
}

- (void)stopObservingHeight {
    if (!self.isObservedHeight) return;
    
    @try {
        [self.tableView removeObserver:self forKeyPath:@"contentSize"];
        [self.textView removeObserver:self forKeyPath:@"contentSize"];
    } @catch (NSException *exception) {
        NSLog(@"Observation exception: %@", exception);
    }
    
    self.isObservedHeight = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"contentSize"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else {
        if ([object isEqual:self.tableView]) {
            
            /* restore content offset */
            if (self.scrollToBottom == YES) {
                [self scrollToBottomAnimated:YES];
            } else {
                [self scrollToBottomSpace];
            }
            
        }
        if ([object isEqual:self.textView]) {
            [self updateTextViewPlaceholderAnimated:YES];
            [self updateTextViewHeightAnimated:YES];
        }
        
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
    
    [self utilizeBottomSpaces];
    
    NSInteger fetchedCount = [fetchedObjects count];
    
    NSInteger count = [self allItemsCount];
    NSInteger expectable = fetchedCount + self.fetchLimit;
    if (count > expectable) {
        self.fetchController.fetchRequest.fetchLimit = expectable;
        self.fetchController.fetchRequest.fetchOffset = count - expectable;
    }
    
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    
    [self.tableView reloadData];
    [self scrollToBottomSpace];
    
}

- (void)utilizeBottomSpaces {
    [self.cellBottomSpaces removeAllObjects];
    
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    if (visibleIndexPaths && [visibleIndexPaths count] > 0) {
        for (NSIndexPath *indexPath in visibleIndexPaths) {
            NSManagedObject *obj = [self modelAtIndexPath:indexPath];
            if (obj == nil) continue;
            
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            CGFloat offset = rect.origin.y - self.tableView.contentOffset.y;
            
            NSDictionary *info = @{
                                   DMChatMessagesViewController_ObjKey:obj,
                                   DMChatMessagesViewController_OffsetKey:@(offset)
                                   };
            [self.cellBottomSpaces addObject:info];
        }
    }
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
    [self tableViewInset];
    
    self.bottomToKeyboardConstraint.constant = height;
    if (height > 0 && self.scrollToBottom) {
        [self scrollToBottomAnimated:NO];
    }
    
    [self.view layoutIfNeeded];
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
    if (self.cellBottomSpaces == nil) return;
    if ([self.cellBottomSpaces count] == 0) return;
    
    for (NSDictionary *info in self.cellBottomSpaces) {
        NSManagedObject *obj = [info objectForKey:DMChatMessagesViewController_ObjKey];
        NSNumber *offset = [info objectForKey:DMChatMessagesViewController_OffsetKey];
        
        NSIndexPath *indexPath = [self.fetchController indexPathForObject:obj];
        if (indexPath == nil) continue;
        
        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
        CGFloat contentOffset = rect.origin.y - offset.doubleValue;
        
        [self.tableView setContentOffset:CGPointMake(0.0, contentOffset)];
        return;
    }
}

#pragma mark - Data access

- (NSUInteger)allItemsCount {
    NSAssert(NO, @"Did you forget implement -(NSUInteger)allItemsCount in you subclass of DMChatMessagesViewController!");
    return 0;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Did you forget implement -(CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath in you subclass of DMChatMessagesViewController!");
    return 44.0;
}

#pragma mark - Access methods

- (NSString *)modelKeyAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Did you forget implement - (NSString *)modelKeyAtIndexPath:(NSIndexPath *)indexPath in you subclass of DMChatMessagesViewController!");
    
    return nil;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSArray <id<NSFetchedResultsSectionInfo>> *secitons = [self.fetchController sections];
    if (secitons == nil || [secitons count] == 0) return nil;
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [secitons objectAtIndex:section];
    if ([sectionInfo numberOfObjects] <= row) return nil;
    
    return [sectionInfo.objects objectAtIndex:row];
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

#pragma mark - Heights

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // clean cache if needed
    CGFloat newWidth = self.tableView.frame.size.width;
    if (self.preferredWidth != newWidth) {
        [self clearAllCache];
        
        self.preferredWidth = newWidth;
    }
    
    // up from cache
    CGFloat height = [self cachedHeightAtIndexPath:indexPath];
    if (height == 0.0) {
        height = [self heightForRowAtIndexPath:indexPath];
    }
    
    // cache it
    [self cacheHeight:height forIndexPath:indexPath];
    
    return height;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    /* prepare for data changes */
    [self utilizeBottomSpaces];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    /* reload data */
    [self.tableView reloadData];
    
    /* restore content offset */
//    if (self.scrollToBottom == YES) {
//        [self scrollToBottomAnimated:YES];
//    } else {
//        [self scrollToBottomSpace];
//    }
}

- (void)tryRefreshRowAtIndexPath:(NSIndexPath *)indexPath {
    // check for visible
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    if (NO == [visibleRows containsObject:indexPath]) return;
    
    [self refreshRowAtIndexPath:indexPath];
    
}

#pragma mark - Cache layer

- (void)clearAllCache {
    [self.estimatedHeights removeAllObjects];
}

- (void)clearCacheAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)cachedHeightAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self modelKeyAtIndexPath:indexPath];
    NSNumber *cachedHeight = [self.estimatedHeights objectForKey:key];
    if (cachedHeight) {
        return cachedHeight.doubleValue;
    }
    
    return 0.0;
}

- (void)cacheHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self modelKeyAtIndexPath:indexPath];
    
    [self.estimatedHeights setObject:@(height) forKey:key];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateTextViewPlaceholderAnimated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self updateTextViewPlaceholderAnimated:YES];
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

#pragma mark - TextField

- (void)updateNewMessageText:(NSString *)text {
    [self updateNewMessageText:text animated:NO];
}

- (void)updateNewMessageText:(NSString *)text animated:(BOOL)animated {
    self.textView.text = text;
    
    [self updateTextViewHeightAnimated:animated];
    [self updateTextViewPlaceholderAnimated:animated];
}

#pragma mark - Append action

- (IBAction)sendMessageAction:(UIButton *)sender {
    self.textView.text = @"";
}

@end
