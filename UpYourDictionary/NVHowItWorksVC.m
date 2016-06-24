//
//  NVHowItWorksVC.m
//  UpYourDictionary
//
//  Created by Admin on 24/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVHowItWorksVC.h"

@interface NVHowItWorksVC ()

@end

@implementation NVHowItWorksVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.labelAbout.text = NSLocalizedString(@"1. Choose dictionary or make it from your own words. Any language is supported! \n2. Push app to background. From this moment notifications with word and translation will be shown. Time interval and number of word you could set in settings. \n3. When notification is arrived, just read it 2-3 times and remove. Eventually each word will be shown 10 times for several days. So you will do learn any words!", "about");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
