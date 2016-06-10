//
//  NVTouchedNotifyVC.h
//  UpYourDictionary
//
//  Created by Admin on 10/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVNotifyInUse.h"
#import "NVNotificationManager.h"
@interface NVTouchedNotifyVC : UITableViewController
@property (strong, nonatomic) NSMutableArray* arrayOfWords;
-(void) refreshTableWithNotify:(UILocalNotification*) notify;
@end
