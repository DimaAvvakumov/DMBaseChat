//
//  ChatViewController.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "ChatViewController.h"

// frameworks
#import <MagicalRecord/MagicalRecord.h>

// core data
#import "ChatMessageEntity.h"

// cells
#import "ChatMessageConfigurator.h"
#import "ChatMessageCell.h"

#define ChatViewCountLimit 20

@interface ChatViewController ()

@property (strong, nonatomic) ChatMessageConfigurator *cellConfigurator;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellConfigurator = [ChatMessageConfigurator new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Method to overwrite

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ChatMessageEntity class])];
    
    // sort
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // limit
//    NSUInteger offset = 0;
//    NSUInteger count = [ChatMessageEntity MR_countOfEntities];
//    if (count > ChatViewCountLimit) {
//        offset = count - ChatViewCountLimit;
//    }
//    
//    if (offset > 0) {
//        fetchRequest.fetchOffset = offset;
//    }
    
    return fetchRequest;
}

- (NSString *)sectionKeyPath {
    return nil;
}

- (void)refreshRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Data access

- (NSUInteger)allItemsCount {
    return [ChatMessageEntity MR_countOfEntities];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSString *)modelKeyAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessageEntity *item = [self modelAtIndexPath:indexPath];
    
    NSString *key = [NSString stringWithFormat:@"message-%@", item];
    return key;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessageEntity *item = [self modelAtIndexPath:indexPath];
    
    // cell configurator
    ChatMessageConfigurator *cellConfigurator = self.cellConfigurator;
    cellConfigurator.item = item;
    cellConfigurator.preferredWidth = self.tableView.frame.size.width;
    
    return [cellConfigurator calculateHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessageEntity *item = [self modelAtIndexPath:indexPath];
    ChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // cell configurator
    ChatMessageConfigurator *cellConfigurator = self.cellConfigurator;
    cellConfigurator.item = item;
    cellConfigurator.preferredWidth = self.tableView.frame.size.width;
    
    // configure
    [cellConfigurator configureCell:cell];
    
    return cell;
}

#pragma mark - Send action

- (IBAction)sendMessageAction:(id)sender {
    NSString *text = self.textView.text;
    if (!text || text.length == 0) return;
    
    self.textView.text = @"";
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        ChatMessageEntity *item = [ChatMessageEntity MR_createEntityInContext:localContext];
        item.messageID = [[NSProcessInfo processInfo] globallyUniqueString];
        item.date = [NSDate date];
        item.isMy = @(YES);
        item.text = text;
    }];
    
}

- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"RU"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    
    return formatter;
}

@end
