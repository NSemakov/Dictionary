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

- (IBAction)buttonCancel:(UIButton *)sender;
- (IBAction)buttonSave:(UIButton *)sender;
-(void) refreshDataWithText:(NSString*) text;
-(void) refreshDataLangToWithText:(NSString*) text;
-(void) refreshDataThemeWithText:(NSString*) text VC:(NVChooseDictThemeVC*) vc;
@end
