//
//  NVChooseLangVC.h
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVParentViewController.h"

@interface NVChooseLangVC : NVParentViewController
- (IBAction)buttonDone:(UIBarButtonItem *)sender;

@property (strong,nonatomic) NSString* currentLang;
@end
