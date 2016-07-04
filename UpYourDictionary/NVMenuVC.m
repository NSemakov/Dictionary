//
//  NVMenuVC.m
//  UpYourDictionary
//
//  Created by Admin on 21/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVMenuVC.h"
#import "NVMainStrategy.h"
@interface NVMenuVC ()

@end

@implementation NVMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NVMainStrategy* manager = [NVMainStrategy sharedManager];
    manager.delegate = self;
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
}

-(void)viewDidAppear:(BOOL)animated{
  

}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showWord:(NSString*) word translation:(NSString*) translation{
    //self.textFieldTest.text = [NSString stringWithFormat:@"%@ - %@",word,translation];
}
#pragma mark - helpers 
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
}
@end
