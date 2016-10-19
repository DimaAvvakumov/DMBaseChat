//
//  DMChatMessageCell.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "DMChatMessageCell.h"

@implementation DMChatMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureSide:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureSide:(BOOL)isLeft {
    if (self.floatRightPinConstraint == nil) return;
    if (self.floatLeftPinConstraint == nil) return;
    
    if (isLeft) {
        [self.contentView removeConstraint:self.floatRightPinConstraint];
        [self.contentView addConstraint:self.floatLeftPinConstraint];
        
        if (self.bubbleView) {
            self.bubbleView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        }
    } else {
        [self.contentView addConstraint:self.floatRightPinConstraint];
        [self.contentView removeConstraint:self.floatLeftPinConstraint];
        
        if (self.bubbleView) {
            self.bubbleView.backgroundColor = [UIColor whiteColor];
        }
    }
}

@end
