//
//  ChatMessageEntity+CoreDataProperties.h
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessageEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *messageID;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *isMy;

@end

NS_ASSUME_NONNULL_END
