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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (IBAction)buttonTestAlgo:(UIButton *)sender {
    //[[NVMainStrategy sharedManager] performAlgo];
    //[[NVMainStrategy sharedManager] startFireAlert];
}*/
-(void) showWord:(NSString*) word translation:(NSString*) translation{
    //self.textFieldTest.text = [NSString stringWithFormat:@"%@ - %@",word,translation];
}
@end
