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
    self.labelAbout.text = NSLocalizedString(@"1. Choose dictionary or make it from your own words. Any language is supported! \n2. Push app to background. From this moment notifications with words and translation will be shown. Time interval and number of word you could set in settings. \n3. When notification is arrived, just read it 2-3 times and remove. Eventually each word will be shown 10 times for several days. So you will do learn any words in calm and relaxed way!", "about");
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion < 8.0f){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
}

@end
