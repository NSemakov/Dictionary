//
//  NVStoreVC.h
//  UpYourDictionary
//
//  Created by Admin on 30/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVStoreCell.h"
#import "RMStore.h"
#import "NVDataManager.h"
@interface NVStoreVC : UIViewController <UITableViewDataSource, UITableViewDelegate , RMStoreObserver>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray * products;
@property (strong,nonatomic) NSArray * productIdentifiers;

- (void)storeDownloadFinished:(NSNotification*)notification __attribute__((availability(ios,introduced=6.0)));
@end
