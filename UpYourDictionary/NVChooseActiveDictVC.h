//
//  NVChooseActiveDictVC.h
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVParentViewController.h"
#import "NVDicts.h"
#import "NVTemplates.h"
//#import "NVMainStrategy.h"
#import "Constants.h"
#import "NVNotificationManager.h"
#import "NVContainerVC.h"
@interface NVChooseActiveDictVC : NVParentViewController
- (IBAction)buttonAdd:(UIBarButtonItem *)sender;
- (IBAction)buttonSave:(UIBarButtonItem *)sender;
- (IBAction)buttonCancel:(UIBarButtonItem *)sender;
- (IBAction)buttonDisableChoise:(UIBarButtonItem *)sender;
@property (strong,nonatomic) NVDicts* curDict;
@property (strong,nonatomic) NVDicts* activeDict;
//@property (nonatomic) IBOutlet UITableView *tableViewReference; // to keep a reference to the tableview
//@property (strong,nonatomic) UIView *viewReference; // a reference to the new background view
@property (strong,nonatomic) UIView* loadingView;
@property (strong,nonatomic) NVContainerVC* loadingVC;
@end
