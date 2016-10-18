//
//  ChatMessageConfigurator.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 18.10.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "ChatMessageConfigurator.h"

// categories
#import <DMCategories/DMCategories.h>

// core data
#import "ChatMessageEntity.h"

// cells
#import "ChatMessageCell.h"

@interface ChatMessageConfigurator()

@property (strong, nonatomic) UIFont *titleFont;

@end

@implementation ChatMessageConfigurator

- (id)init {
    self = [super init];
    if (self) {
        self.item = nil;
        self.preferredWidth = 320.0;
        self.titleFont = [UIFont systemFontOfSize:15.0];
    }
    return self;
}

- (CGFloat)calculateHeight {
    if (self.item == nil) return 0;
    ChatMessageEntity *item = self.item;
    
    CGFloat avaliableWidth = self.preferredWidth - 24.0 - 12.0;
    
    CGSize size = [item.text textSizeWithFont:self.titleFont width:avaliableWidth inSingleLine:NO];
    
    return size.height + 8.0 + 16.0;
}

- (void)configureCell:(ChatMessageCell *)cell {
    ChatMessageEntity *item = self.item;
    
    cell.messageLabel.text = item.text;
    
    if (item.isMy.boolValue) {
        [cell configureSide:NO];
    } else {
        [cell configureSide:YES];
    }
}

@end
