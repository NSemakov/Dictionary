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
@interface NVCreateTemplateVC : NVParentViewController
@property (strong,nonatomic) NVTemplates* templateNew;
@property (strong,nonatomic) NVWords* word;
@property (strong,nonatomic) NSMutableSet* tempWordsSet;
@property (strong,nonatomic) NSManagedObjectContext* childContext;
- (IBAction)buttonAddWord:(UIBarButtonItem *)sender;
- (IBAction)buttonSaveTemplate:(UIButton *)sender;
- (IBAction)buttonCancel:(UIButton *)sender;

@end
