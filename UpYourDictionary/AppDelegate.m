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
    UIUserNotificationType types = UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    NSLog(@"did finish launching with options");
    [[NVNotificationManager sharedManager] refreshProgressOfDictionary];
    return YES;
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{

}
-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    //NSLog(@"received:body %@, date %@",notification.alertBody,notification.fireDate);
    
    [[self window] makeKeyAndVisible];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*) self.window.rootViewController;
    UIViewController* lastStackVC = [[navigationController viewControllers] lastObject];
    NVTouchedNotifyVC *vc = nil;
    if ([lastStackVC isKindOfClass:[NVTouchedNotifyVC class]]){
        //контроллер показывающий нотифаи уже открыт
        vc = (NVTouchedNotifyVC*) lastStackVC;
        [vc refreshTableWithNotify:notification];
    } else {
        //если это не контроллер нотификаций, значит это первое нажатие на нотифай
        vc = [storyboard instantiateViewControllerWithIdentifier:@"NVTouchedNotifyVC"];
        [vc refreshTableWithNotify:notification];
        [lastStackVC.navigationController showViewController:vc sender:nil];
    }
    [[NVNotificationManager sharedManager] refreshProgressOfDictionary];
    [[NVNotificationManager sharedManager] addNewNotificationToFullSet];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[[NVMainStrategy sharedManager] startFireAlert];
}
- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[NVNotificationManager sharedManager] addNewNotificationToFullSet];
        completionHandler(UIBackgroundFetchResultNewData);
}
- (void)applicationWillEnterForeground:(UIApplication *)application {


}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NVNotificationManager sharedManager] refreshProgressOfDictionary];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
