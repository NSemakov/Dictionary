//
//  NVCreateNewDict.h
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVParentViewController.h"
#import "NVDicts.h"
#import "NVTemplates.h"
#import "NVDataManager.h"
#import "NVServerManager.h"
#import "NVChooseDictThemeVC.h"
#import "NVCommonManager.h"
#import "NVLangFromVC.h"
#import "NVLangToVC.h"
@class NVChooseDictThemeVC;

@protocol NVLangFromVCProtocol;
@protocol NVLangToVCProtocol;
@protocol NVChooseDictThemeVCProtocol;

@interface NVCreateNewDictVC : UITableViewController <NVLangFromVCProtocol,NVLangToVCProtocol, NVChooseDictThemeVCProtocol>
@property (weak, nonatomic) IBOutlet UILabel *textFieldLangFrom;
@property (weak, nonatomic) IBOutlet UILabel *textFieldLangTo;
@property (weak, nonatomic) IBOutlet UILabel *textFieldDictTheme;
@property (strong,nonatomic) NVTemplates* templateForDict;
@property (strong,nonatomic) NVDicts* dict;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *langFromShort;
@property (strong, nonatomic) NSString *langToShort;

- (IBAction)buttonSave:(UIBarButtonItem *)sender;
- (IBAction)actionBackButton:(UIBarButtonItem *)sender;
-(void) refreshDataWithText:(NSString*) text shortLangFrom:(NSString*) shortLangFrom;
-(void) refreshDataLangToWithText:(NSString*) text shortLangTo:(NSString*) shortLangTo;
-(void) refreshDataThemeWithTemplate:(NVTemplates*) templ;
@end
