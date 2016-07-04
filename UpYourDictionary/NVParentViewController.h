//
//  NVParentViewController.h
//  41-44.CoreData
//
//  Created by Admin on 24.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NVCommonManager.h"
@interface NVParentViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource,UITableViewDelegate ,UISearchBarDelegate>
@property (strong,nonatomic) NSFetchedResultsController*  fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
