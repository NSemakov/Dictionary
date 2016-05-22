//
//  AppDelegate.m
//  UpYourDictionary
//
//  Created by Admin on 15/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    UIUserNotificationType types = UIUserNotificationTypeBadge| UIUserNotificationTypeSound| UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    NSLog(@"did finish launching with options");

    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    return YES;
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{

}
-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"received");
}
- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[[NVMainStrategy sharedManager] startFireAlert];
}
- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    UILocalNotification* notify = [UIApplication sharedApplication].scheduledLocalNotifications.firstObject;
        NSLog(@"Notification : %@",notify.alertBody);
    NSTimeInterval originalTime = [notify.fireDate timeIntervalSinceReferenceDate];
    NSTimeInterval curTime = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = curTime - originalTime;
    NSLog(@"elapsed %f",elapsed);
    if (elapsed > 30){
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[NVMainStrategy sharedManager] startFireAlert];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
    for (UILocalNotification* notify in [UIApplication sharedApplication].scheduledLocalNotifications) {
        NSLog(@"Notification: %@",notify.alertBody);
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSLog(@"Notification after");
    for (UILocalNotification* notify in [UIApplication sharedApplication].scheduledLocalNotifications) {
        NSLog(@"Notification : %@",notify.alertBody);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}

@end
