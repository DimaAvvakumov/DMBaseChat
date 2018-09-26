//
//  DMCategories.h
//  DMCategories
//
//  Created by Dmitry Avvakumov on 18.10.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#ifndef DMCategories_h
#define DMCategories_h

#define DM_SYSTEM_VERSIONEQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define DM_SYSTEM_VERSIONGREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define DM_SYSTEM_VERSIONGREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define DM_SYSTEM_VERSIONLESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define DM_SYSTEM_VERSIONLESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "UIView+DMAnimation.h"
#import "UIButton+BackgroundColor.h"
#import "UIButton+NoAnimation.h"
#import "UIButton+TemporaryDisabled.h"
#import "UIViewController+KeyboardBehavior.h"
#import "NSDictionary+SimpleGetters.h"
#import "NSString+TextSize.h"
#import "UIView+DMGeometry.h"
#import "UIColor+DMInterpolate.h"
#import "UIView+Recursion.h"
#import "UIImage+TintedImage.h"

#endif /* DMCategories_h */
