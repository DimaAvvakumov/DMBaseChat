//
//  ChatMessageConfigurator.h
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 18.10.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ChatMessageEntity, ChatMessageCell;

@interface ChatMessageConfigurator : NSObject

@property (strong, nonatomic) ChatMessageEntity *item;
@property (assign, nonatomic) CGFloat preferredWidth;

- (CGFloat)calculateHeight;
- (void)configureCell:(ChatMessageCell *)cell;

@end
