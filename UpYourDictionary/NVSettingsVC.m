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
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    /*time to push and number of words*/    
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
    
    /**/
    TTRangeSlider* sliderDayTimeChoice =[[TTRangeSlider alloc] init];
    sliderDayTimeChoice.delegate = self;
    //slider Day Time set up
    sliderDayTimeChoice.minValue = 0;
    sliderDayTimeChoice.maxValue = 24;
    NSInteger minimumDayTimeValue = [[NSUserDefaults standardUserDefaults] integerForKey:NVMinimumDayTimeAllowedForNotification];
    if (minimumDayTimeValue != 0) {
        sliderDayTimeChoice.selectedMinimum = minimumDayTimeValue;
    }
    
    NSInteger maximumDayTimeValue = [[NSUserDefaults standardUserDefaults] integerForKey:NVMaximumDayTimeAllowedForNotification];
    if (maximumDayTimeValue != 0) {
        sliderDayTimeChoice.selectedMaximum = maximumDayTimeValue;
    }
    self.labelArriveNotifies.text = [self formatTimeOfNotifiesArrivingSettingString:minimumDayTimeValue valueTo:maximumDayTimeValue];
    sliderDayTimeChoice.hideLabels = YES;
    sliderDayTimeChoice.minDistance = 1;
    sliderDayTimeChoice.enableStep = YES;
    sliderDayTimeChoice.step = 1;
    //sliderDayTimeChoice.handleImage =[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Images/Handler" ofType:@"png"]];
    sliderDayTimeChoice.handleDiameter = 29.f;
    sliderDayTimeChoice.handleColor = [UIColor colorWithRed:0/255.f  green:119/255.f  blue:250/255.f alpha:1];
    sliderDayTimeChoice.selectedHandleDiameterMultiplier = 1.f;
    sliderDayTimeChoice.tintColorBetweenHandles = [UIColor colorWithRed:0/255.f  green:119/255.f  blue:250/255.f alpha:1];
    sliderDayTimeChoice.lineHeight = 2.2f;
    sliderDayTimeChoice.tintColor = [UIColor colorWithRed:180/255.f  green:180/255.f  blue:180/255.f  alpha:1];
    sliderDayTimeChoice.translatesAutoresizingMaskIntoConstraints = NO;
    self.sliderDayTime = sliderDayTimeChoice;
    [self.cellForDayTimeSlider.contentView addSubview:self.sliderDayTime];
    NSDictionary *viewsDictionary = @{@"sliderDayTime":self.sliderDayTime};
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[sliderDayTime]-(-6)-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[sliderDayTime]-(10)-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    [self.cellForDayTimeSlider.contentView addConstraints:constraint_POS_V];
    [self.cellForDayTimeSlider.contentView addConstraints:constraint_POS_H];
    
    
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
    return 4;
}

#pragma mark TTRangeSliderDelegate
-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
    self.labelArriveNotifies.text = [self formatTimeOfNotifiesArrivingSettingString:selectedMinimum valueTo:selectedMaximum];
    [self calculateInfo];
}
#pragma mark - helper methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueShowDownLoadingScreen2"]) {
        NVContainerVC* vc = segue.destinationViewController;
        vc.stringToSet = NSLocalizedString(@"Changing settings in all dictionaries. Please wait about 20 sec. On success this message will disapper.", nil);
        self.loadingVC = vc;
    }
}
-(void) calculateInfo{
    //50 * countAim / lroundf(self.sliderNumberOfWords.value) - кол-во нотификаций
    //если 6, то 6 * TimeToPush = всего часов необходимо.
    NSInteger daysToKnowDict = (50 * countAim / lroundf(self.sliderNumberOfWords.value) * lroundf(self.sliderTimeToPush.value)) / (self.sliderDayTime.selectedMaximum-self.sliderDayTime.selectedMinimum) + 1;
    
    self.labelInfo.text = [NSString stringWithFormat:NSLocalizedString(@"Info. With these settings you will know any 50 words in: %d day(s)", nil), daysToKnowDict];
}
-(NSString*) formatTimeSettingString:(NSInteger) value{
    return [NSString stringWithFormat:NSLocalizedString(@"Time interval to show words: %d hour(s)", nil), value];
}
-(NSString*) formatWordNumberSettingString:(NSInteger) value{
    return [NSString stringWithFormat:NSLocalizedString(@"Number of words in one time: %d", nil), value];
}
-(NSString*) formatTimeOfNotifiesArrivingSettingString:(NSInteger) valueFrom valueTo:(NSInteger) valueTo{
    NSString* stringValueFrom = (valueFrom < 10) ? [NSString stringWithFormat:@"0%ld:00",valueFrom] : [NSString stringWithFormat:@"%ld:00",valueFrom];
    
    NSString* stringValueTo;
    if (valueTo == 24) {
        stringValueTo = [NSString stringWithFormat:@"23:59"];
    } else {
        stringValueTo = (valueTo < 10) ? [NSString stringWithFormat:@"0%ld:00",valueTo] : [NSString stringWithFormat:@"%ld:00",valueTo];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"Time when notifications arrive: %@-%@", nil), stringValueFrom, stringValueTo];
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

    //get initial values
    NSInteger timeToPush = [[[NSUserDefaults standardUserDefaults] valueForKey:NVTimeToPush] integerValue];
    NSInteger numberOfWordsToShow = [[[NSUserDefaults standardUserDefaults] valueForKey:NVNumberOfWordsToShow] integerValue];
    NSInteger savedDayTimeMinValue = [[[NSUserDefaults standardUserDefaults] valueForKey:NVMinimumDayTimeAllowedForNotification] integerValue];
    NSInteger savedDayTimeMaxValue = [[[NSUserDefaults standardUserDefaults] valueForKey:NVMaximumDayTimeAllowedForNotification] integerValue];
    // save slider's value
    int sliderValueTime;
    sliderValueTime = self.sliderTimeToPush.value;
    int sliderValueNumberOfWords;
    sliderValueNumberOfWords = self.sliderNumberOfWords.value;
    int sliderDayTimeMinValue;
    sliderDayTimeMinValue = self.sliderDayTime.selectedMinimum;
    int sliderDayTimeMaxValue;
    sliderDayTimeMaxValue = self.sliderDayTime.selectedMaximum;
    //NSLog(@"min value saved: %ld, min value selected: %d, max value saved: %ld, max value selected: %d",(long)savedDayTimeMinValue, sliderDayTimeMinValue,(long)savedDayTimeMaxValue,  sliderDayTimeMaxValue);
    if (sliderValueTime == timeToPush &&
        sliderValueNumberOfWords == numberOfWordsToShow &&
        sliderDayTimeMinValue == savedDayTimeMinValue &&
        sliderDayTimeMaxValue == savedDayTimeMaxValue) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:sliderValueTime forKey:NVTimeToPush];
        [[NSUserDefaults standardUserDefaults] setInteger:sliderValueNumberOfWords forKey:NVNumberOfWordsToShow];
        [[NSUserDefaults standardUserDefaults] setInteger:sliderDayTimeMinValue forKey:NVMinimumDayTimeAllowedForNotification];
        [[NSUserDefaults standardUserDefaults] setInteger:sliderDayTimeMaxValue forKey:NVMaximumDayTimeAllowedForNotification];
        //create local notifications in background
        [self performSegueWithIdentifier:@"segueShowDownLoadingScreen2" sender:nil];
        [self.loadingVC generateNotifiesAndRefreshAfterWithText:NSLocalizedString(@"Settings are saved!", nil) withDict:nil sender:self];
    }
}

- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
