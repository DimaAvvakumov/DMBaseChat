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

#import "NSString+Fish.h"

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
    
    [self updateNewMessageText:@"asd asd ads" animated:NO];
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

- (NSManagedObjectContext *)fetchManagedObjectContext {
    return [NSManagedObjectContext MR_defaultContext];
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
    
    CGFloat height = [cellConfigurator calculateHeight];
    
    return height;
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

#pragma mark - Append data

- (IBAction)appendSelector:(id)sender {
    
    [self appendData];
}

- (void)appendData {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        for (int i = 1; i < 20; i++) {
            NSTimeInterval offset = i * 60.0 * 3.0 * 24.0;
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow: - offset];
            NSString *dateStr = [[self dateFormatter] stringFromDate:date];
            int r = arc4random_uniform(100);
            BOOL isMy = (r > 50) ? YES : NO;
            
            
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:10];
            [info setObject:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"messageID"];
            [info setObject:dateStr forKey:@"date"];
            [info setObject:@(isMy) forKey:@"isMy"];
            [info setObject:[NSString generateRandomFishWithLength:128] forKey:@"text"];
            
            [ChatMessageEntity MR_importFromObject:info inContext:localContext];
        }
    }];
}


@end
