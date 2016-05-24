//
//  NVNotificationManager.m
//  UpYourDictionary
//
//  Created by Admin on 24/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVNotificationManager.h"

@implementation NVNotificationManager
+(NVNotificationManager*) sharedManager{
    static NVNotificationManager* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVNotificationManager alloc]init];
    });
    return manager;
}

-(void) startFireAlertAtDate:(NSDate*) fireDate{
    //take settings like number of words, frequency in hours
    NSTimeInterval interval;
    //interval = 60;//12 hours from now
    NVContent* contentToShow = [[NVMainStrategy sharedManager] algoResultHandler];
    if (!contentToShow) { //не работаем без активного словаря
        return;
    }
    
    NSString* stringToShow = [NSString stringWithFormat:@"%@ - %@",contentToShow.word,contentToShow.translation];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate ; //Enter the time here in seconds.
    localNotification.alertBody= stringToShow;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval= 0; //Repeating instructions here.
    localNotification.soundName= UILocalNotificationDefaultSoundName;
    localNotification.userInfo =[NSDictionary dictionaryWithObjectsAndKeys:contentToShow,@"contentToShow", nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    
}
@end
