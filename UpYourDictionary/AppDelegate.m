//
//  AppDelegate.m
//  UpYourDictionary
//
//  Created by Admin on 15/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AppDelegate.h"
@import Firebase;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[NVCommonManager sharedManager]configureInitialState];//bar style
    
    [RMStore defaultStore];//add observer of storeKit
    [self setUpFirebaseOnAppDidStart];
    
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    if([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType types = UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    else {
        
    }
    //if app is launched after local notify tap
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        [self actionAfterLocalNotificationArrived:notification];
    }
    
    //Check if its first time. if first, cancel all previous notifies
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NVIsFirstTimeLaunched]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:NVIsFirstTimeLaunched];
        
        [application cancelAllLocalNotifications]; // Restart the Local Notifications list
        
        //initial settings
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:NVTimeToPush];
        [[NSUserDefaults standardUserDefaults] setInteger:9 forKey:NVNumberOfWordsToShow];
        [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:NVMinimumDayTimeAllowedForNotification];
        [[NSUserDefaults standardUserDefaults] setInteger:23 forKey:NVMaximumDayTimeAllowedForNotification];
    }
    NSLog(@"did finish launching with options");
    [[NVNotificationManager sharedManager] refreshProgressOfDictionaryWithCallback:nil];
    return YES;
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{

}
-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"received:body %@, date %@",notification.alertBody,notification.fireDate);
    [self actionAfterLocalNotificationArrived:notification];
    
    [[NVNotificationManager sharedManager] refreshProgressOfDictionaryWithCallback:^{
        [[NVNotificationManager sharedManager] addNewNotificationToFullSet];
    }];
    
}
- (void)actionAfterLocalNotificationArrived:(UILocalNotification*) notification{
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
        //if([lastStackVC.navigationController respondsToSelector:@selector(showViewController:sender:)])
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([lastStackVC.navigationController respondsToSelector:@selector(showViewController:sender:)]) {
                [lastStackVC.navigationController showViewController:vc sender:nil];
            } else {
                [lastStackVC.navigationController pushViewController:vc animated:YES];
            }
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
        
        
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    [[NVNotificationManager sharedManager].queue cancelAllOperations];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NVNotificationManager sharedManager].queue cancelAllOperations];
}
- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[NVNotificationManager sharedManager] addNewNotificationToFullSet];
        completionHandler(UIBackgroundFetchResultNewData);
}
- (void)applicationWillEnterForeground:(UIApplication *)application {


}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NVNotificationManager sharedManager] refreshProgressOfDictionaryWithCallback:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[NVNotificationManager sharedManager].queue cancelAllOperations];
}

- (void) setUpFirebaseOnAppDidStart {
    [FIRApp configure]; //api from fireBase  configure
    FIRDatabaseReference *rootRef= [[FIRDatabase database] reference];
    [NVServerManager sharedManager].remoteDB = rootRef;
    FIRDatabaseReference* childAPIKeys = [rootRef child:@"APIKeys"];
    [childAPIKeys observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
        NSString* APIDictKey = [snapshot.value  objectForKey:@"APIDictKey"];
        if (APIDictKey.length > 0) {
            [NVServerManager sharedManager].APIDictKey = APIDictKey;
        }
        NSString* APITranslatorKey = [snapshot.value objectForKey:@"APITranslatorKey"];
        if (APITranslatorKey.length > 0) {
            [NVServerManager sharedManager].APITranslatorKey = APITranslatorKey;
        }
        
    }];
    FIRDatabaseReference* childProductIdentifiers = [rootRef child:@"ProductIdentifiers"];
    [childProductIdentifiers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
      // NSLog(@"%@ -> %@", snapshot.key, snapshot.value);

        NSArray* productIdentifiers = [snapshot.value allValues];
        if (productIdentifiers) {
            //NSLog(@"pr ids %@",productIdentifiers);
            [RMStore defaultStore].productIdentifiers = productIdentifiers;
        }
        
    }];
    /*
    [[NVServerManager sharedManager] POSTSearchInCachedWordsAtFirebase:@"Столer" fromLang:@"ru" toLang:@"en" OnSuccess:^(NSString *translation) {
        NSLog(@"%@",translation);
    } onFailure:^(NSString *error) {
        NSLog(@"%@",error);
    }];
     */
    /*
    [[NVServerManager sharedManager] POSTAddToCachedWordsAtFirebase:@"Стол" translation:@"Table" fromLang:@"ru" toLang:@"en" OnSuccess:^(NSString *translation) {
        
    } onFailure:^(NSString *error) {
        
    }];
     */
}
@end
