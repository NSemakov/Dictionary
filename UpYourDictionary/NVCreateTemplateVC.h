//
//  NVCreateTemplateVC.h
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVParentViewController.h"
#import "NVTemplates.h"
#import "NVWords.h"
#import "NVDataManager.h"
#import "NVCreateTemplateCell.h"
@interface NVCreateTemplateVC : UITableViewController
@property (strong,nonatomic) NVTemplates* templateNew;
@property (strong,nonatomic) NVWords* word;
@property (strong,nonatomic) NSMutableArray* tempWordsSet;
@property (strong,nonatomic) NSManagedObjectContext* childContext;
@property (strong,nonatomic) NSString* templateName;
@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;
- (IBAction)buttonAddWord:(UIBarButtonItem *)sender;
- (IBAction)buttonSaveTemplate:(UIBarButtonItem *)sender;
- (IBAction)buttonCancel:(UIBarButtonItem *)sender;

@end
