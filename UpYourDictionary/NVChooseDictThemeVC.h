//
//  NVChooseDictThemeVC.h
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVParentViewController.h"
#import "NVTemplates.h"
#import "NVCreateTemplateVC.h"
#import "NVChooseDictThemeCell.h"
@protocol NVChooseDictThemeVCProtocol;

@interface NVChooseDictThemeVC : NVParentViewController <UIActionSheetDelegate>
@property (strong,nonatomic) id<NVChooseDictThemeVCProtocol> delegate;
@property (strong,nonatomic) NVTemplates* curTemplate;
@property (strong,nonatomic) UIAlertController* alertCtrl;

- (IBAction)buttonAddOwnWords:(UIBarButtonItem *)sender;
- (IBAction)buttonOk:(UIBarButtonItem *)sender;


@end


@protocol NVChooseDictThemeVCProtocol
-(void) refreshDataThemeWithTemplate:(NVTemplates*) templ;
@end