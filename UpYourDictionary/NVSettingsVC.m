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
        self.labelTimeToPush.text =[NSString stringWithFormat:@"Time to push:%d hour(s)",timeToPush];
        [self.sliderTimeToPush setValue:timeToPush animated:YES];
    } else {
        sliderValue = lroundf(self.sliderTimeToPush.value);
        self.labelTimeToPush.text =[NSString stringWithFormat:@"Time to push:%d hour(s)",sliderValue];
    }
    
    NSInteger numberOfWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
    if (numberOfWords != 0) {
        self.labelNumberOfWords.text =[NSString stringWithFormat:@"Number of words:%d",numberOfWords];
        [self.sliderNumberOfWords setValue:numberOfWords animated:YES];
    } else {
        sliderValue = lroundf(self.sliderNumberOfWords.value);
        self.labelNumberOfWords.text =[NSString stringWithFormat:@"Number of words:%d",sliderValue];
    }
    
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
    return 2;
}
#pragma mark - actions
- (IBAction)sliderActionTimeToPush:(UISlider *)sender {
    
    int sliderValue;
    sliderValue = lroundf(sender.value);
    [sender setValue:sliderValue animated:YES];
    self.labelTimeToPush.text =[NSString stringWithFormat:@"Time to push:%d hour(s)",sliderValue];

}

- (IBAction)sliderActionNumberOfWords:(UISlider *)sender {
    
    int sliderValue;
    sliderValue = lroundf(sender.value);
    [sender setValue:sliderValue animated:YES];
    self.labelNumberOfWords.text =[NSString stringWithFormat:@"Number of words:%d",sliderValue];
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
