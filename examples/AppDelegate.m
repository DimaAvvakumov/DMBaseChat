//
//  AppDelegate.m
//  DMBaseChat
//
//  Created by Dmitry Avvakumov on 31.08.16.
//  Copyright © 2016 Dmitry Avvakumov. All rights reserved.
//

#import "AppDelegate.h"

#import <MagicalRecord/MagicalRecord.h>
#import <StandardPaths/StandardPaths.h> 

#import "NSString+Fish.h"

#import "ChatMessageEntity.h"
#include <stdlib.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self printHomeFolder];
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelError];
    
    [self initData];
    
    return YES;
}

- (void)initData {
    NSUInteger count = [ChatMessageEntity MR_countOfEntities];
    if (count > 0) return;
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        for (int i = 1; i < 100; i++) {
            NSTimeInterval offset = i * 60.0 * 3.0;
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

- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"RU"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    
    return formatter;
}

- (void)printHomeFolder {
    // application home folder
    NSLog(@"+---------------+");
    NSLog(@"|  Home folder  |");
    NSLog(@"+---------------+\n%@\n\n", [[NSFileManager defaultManager] cacheDataPath]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
