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
@class NVChooseDictThemeVC;

@protocol NVLangFromVCProtocol;
@protocol NVLangToVCProtocol;
@protocol NVChooseDictThemeVCProtocol;

@interface NVCreateNewDictVC : UITableViewController <NVLangFromVCProtocol,NVLangToVCProtocol, NVChooseDictThemeVCProtocol>
@property (weak, nonatomic) IBOutlet UITextField *textFieldLangFrom;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLangTo;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDictTheme;
@property (strong,nonatomic) NVTemplates* templateForDict;
@property (strong,nonatomic) NVDicts* dict;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *langFromShort;
@property (strong, nonatomic) NSString *langToShort;

- (IBAction)buttonCancel:(UIBarButtonItem *)sender;
- (IBAction)buttonSave:(UIBarButtonItem *)sender;
-(void) refreshDataWithText:(NSString*) text shortLangFrom:(NSString*) shortLangFrom;
-(void) refreshDataLangToWithText:(NSString*) text shortLangTo:(NSString*) shortLangTo;
-(void) refreshDataThemeWithTemplate:(NVTemplates*) templ;
@end
