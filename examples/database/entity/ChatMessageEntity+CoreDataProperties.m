//
//  ChatMessageEntity+CoreDataProperties.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessageEntity+CoreDataProperties.h"

@implementation ChatMessageEntity (CoreDataProperties)

@dynamic messageID;
@dynamic text;
@dynamic date;
@dynamic isMy;

@end
