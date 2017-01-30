//
//  ChatMessageEntity.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "ChatMessageEntity.h"

@implementation ChatMessageEntity

- (NSString *)description {
    NSString *desc = [super description];
    
    NSMutableArray *pices = [NSMutableArray arrayWithCapacity:10];
    
    [pices addObject:[NSString stringWithFormat:@"%@", desc]];
    [pices addObject:[NSString stringWithFormat:@"\ttext: %@", self.text]];
    
    return [pices componentsJoinedByString:@"\n"];
}

@end
