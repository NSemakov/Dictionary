//
//  NVSettingsVC.m
//  UpYourDictionary
//
//  Created by Admin on 24/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVSettingsVC.h"

@interface NVSettingsVC ()

@end

@implementation NVSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //initialize labels
    
    int sliderValue;
    NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
    if (timeToPush != 0) {
        self.labelTimeToPush.text =[self formatTimeSettingString:timeToPush];
        

        [self.sliderTimeToPush setValue:timeToPush animated:YES];
    } else {
        sliderValue = lroundf(self.sliderTimeToPush.value);
        self.labelTimeToPush.text = [self formatTimeSettingString:sliderValue];
    }
    
    NSInteger numberOfWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
    if (numberOfWords != 0) {
        self.labelNumberOfWords.text = [self formatWordNumberSettingString:numberOfWords];
        [self.sliderNumberOfWords setValue:numberOfWords animated:YES];
    } else {
        sliderValue = lroundf(self.sliderNumberOfWords.value);
        self.labelNumberOfWords.text = [self formatWordNumberSettingString:sliderValue];
    }
    [self calculateInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
#pragma mark - helper methods
-(void) calculateInfo{
    NSInteger daysToKnowDict = (50 * countAim / lroundf(self.sliderNumberOfWords.value) * lroundf(self.sliderTimeToPush.value)) / 24 + 1;
    
    self.labelInfo.text = [NSString stringWithFormat:NSLocalizedString(@"Info. With these settings you will know any 50 words in: %d day(s)", nil), daysToKnowDict];
}
-(NSString*) formatTimeSettingString:(NSInteger) value{
    return [NSString stringWithFormat:NSLocalizedString(@"Time interval to show words: %d hour(s)", nil), value];
}
-(NSString*) formatWordNumberSettingString:(NSInteger) value{
    return [NSString stringWithFormat:NSLocalizedString(@"Number of words in one time: %d", nil), value];
}
#pragma mark - actions
- (IBAction)sliderActionTimeToPush:(UISlider *)sender {
    
    int sliderValue;
    sliderValue = lroundf(sender.value);
    [sender setValue:sliderValue animated:YES];
    self.labelTimeToPush.text = [self formatTimeSettingString:sliderValue];
    [self calculateInfo];
}

- (IBAction)sliderActionNumberOfWords:(UISlider *)sender {
    
    int sliderValue;
    sliderValue = lroundf(sender.value);
    [sender setValue:sliderValue animated:YES];
    self.labelNumberOfWords.text = [self formatWordNumberSettingString:sliderValue];
    [self calculateInfo];
}

- (IBAction)buttonSave:(UIBarButtonItem *)sender {

    // save slider's value
    int sliderValue;
    sliderValue = self.sliderTimeToPush.value;
    [[NSUserDefaults standardUserDefaults] setInteger:sliderValue forKey:NVTimeToPush];
    
    sliderValue = self.sliderNumberOfWords.value;
    [[NSUserDefaults standardUserDefaults] setInteger:sliderValue forKey:NVNumberOfWordsToShow];
        //create local notifications in background
    [[NVNotificationManager sharedManager] generateNewNotifications];
        
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
