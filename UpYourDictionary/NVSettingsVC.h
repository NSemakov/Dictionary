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
#import "NVContainerVC.h"
#import "TTRangeSlider.h"
@interface NVSettingsVC : UITableViewController <TTRangeSliderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelTimeToPush;
@property (weak, nonatomic) IBOutlet UILabel *labelNumberOfWords;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelArriveNotifies;
@property (weak, nonatomic) IBOutlet UISlider *sliderTimeToPush;
@property (weak, nonatomic) IBOutlet UISlider *sliderNumberOfWords;
@property (strong, nonatomic) NVContainerVC* loadingVC;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTimeToPush;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellNumberOfWords;
@property (strong, nonatomic) TTRangeSlider *sliderDayTime;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellForDayTimeSlider;
- (IBAction)sliderActionTimeToPush:(UISlider *)sender;

- (IBAction)sliderActionNumberOfWords:(UISlider *)sender;
- (IBAction)buttonSave:(UIBarButtonItem *)sender;
- (IBAction)buttonCancel:(UIBarButtonItem *)sender;


@end
