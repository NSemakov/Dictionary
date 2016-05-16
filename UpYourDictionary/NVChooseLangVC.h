//
//  NVChooseLangVC.h
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NVChooseLangVC : UITableViewController 
- (IBAction)buttonDone:(UIBarButtonItem *)sender;

@property (strong,nonatomic) NSString* currentLang;
@end
