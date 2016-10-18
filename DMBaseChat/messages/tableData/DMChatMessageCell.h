//
//  DMChatMessageCell.h
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMChatMessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIView *bubbleView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *floatLeftPinConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *floatRightPinConstraint;

- (void)configureSide:(BOOL)isLeft;

@end
