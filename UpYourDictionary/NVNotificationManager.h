//
//  NVNotificationManager.h
//  UpYourDictionary
//
//  Created by Admin on 24/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVStrategyProtocol.h" //not in use
#import "NVMainStrategy.h"
#import "NVDicts.h"
#import "NVContent.h"
#import "Constants.h"
#import "NVNotifyInUse.h"
@protocol NVNotificationManagerRefreshProgressBarProtocol <NSObject>

- (void) refreshProgressBar;

@end

@interface NVNotificationManager : NSObject

@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;
@property (weak,nonatomic) id <NVNotificationManagerRefreshProgressBarProtocol> delegateToRefresh;
@property (strong,nonatomic) NSOperationQueue* queue;
@property (strong,nonatomic) NSBlockOperation* operation;
//-(void) generateNewNotificationsWithCallback:(void(^)(NSInteger counter))callback;
-(void) generateNewNotificationsForDict:(NVDicts*) dict withCallback:(void(^)(NSInteger counter))callback;
-(void) cancelNotificationsCompleteWayWithCallback:(void(^)(void)) callback;
-(void) addNewNotificationToFullSet;
-(NVNotifyInUse*) fetchedNotifyWithDate:(NSDate*) fireDate;
-(void) refreshProgressOfDictionaryWithCallback:(void(^)(void))callback;
+(NVNotificationManager*) sharedManager;

@end
