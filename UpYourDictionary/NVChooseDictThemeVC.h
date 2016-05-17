//
//  NVChooseDictThemeVC.h
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVParentViewController.h"
#import "NVTemplates.h"

@protocol NVChooseDictThemeVCProtocol;

@interface NVChooseDictThemeVC : NVParentViewController
@property (strong,nonatomic) id<NVChooseDictThemeVCProtocol> delegate;
@property (strong,nonatomic) NVTemplates* curTemplate;
@end


@protocol NVChooseDictThemeVCProtocol
-(void) refreshDataThemeWithText:(NSString*) text VC:(NVChooseDictThemeVC*) vc;
@end