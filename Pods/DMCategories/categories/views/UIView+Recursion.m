//
//  UIView+Recursion.m
//  DMCategories
//
//  Created by Dmitry Avvakumov on 26.06.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "UIView+Recursion.h"

@implementation UIView (Recursion)

- (NSArray <UIView *> *)allSubviews {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    [arr addObject:self];
    for (UIView *subview in self.subviews) {
        [arr addObjectsFromArray: [subview allSubviews]];
    }
    return arr;
}

@end
