//
//  NVSettingsVC.h
//  UpYourDictionary
//
//  Created by Admin on 24/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
//#import "NVMainStrategy.h"
#import "NVNotificationManager.h"
@interface NVSettingsVC : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *labelTimeToPush;
@property (weak, nonatomic) IBOutlet UILabel *labelNumberOfWords;
@property (weak, nonatomic) IBOutlet UISlider *sliderTimeToPush;
@property (weak, nonatomic) IBOutlet UISlider *sliderNumberOfWords;
- (IBAction)sliderActionTimeToPush:(UISlider *)sender;
- (IBAction)sliderActionNumberOfWords:(UISlider *)sender;
- (IBAction)buttonSave:(UIBarButtonItem *)sender;
- (IBAction)buttonCancel:(UIBarButtonItem *)sender;

@end
