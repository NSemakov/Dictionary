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
@interface NVChooseActiveDictVC : NVParentViewController
- (IBAction)buttonAdd:(UIBarButtonItem *)sender;
- (IBAction)buttonSave:(UIBarButtonItem *)sender;
- (IBAction)buttonCancel:(UIBarButtonItem *)sender;
- (IBAction)buttonDisableChoise:(UIBarButtonItem *)sender;
@property (strong,nonatomic) NVDicts* curDict;
@property (strong,nonatomic) NVDicts* activeDict;
@end
