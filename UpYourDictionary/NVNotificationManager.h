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
@interface NVNotificationManager : NSObject
+(NVNotificationManager*) sharedManager;

-(void) generateNewNotifications;
-(void) addNewNotificationToFullSet;
@end
