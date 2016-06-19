//
//  NVContainerVC.m
//  UpYourDictionary
//
//  Created by Admin on 17/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVContainerVC.h"

@interface NVContainerVC ()

@end

@implementation NVContainerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.stringToSet) {
        self.labelOfViewLoading.text = self.stringToSet;
    }
    if (self.indicatorHidden) {
        [self.indicator stopAnimating];
    }
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(isDownloadEnd) userInfo:nil repeats:NO];

}
- (void)setIndicatorHidden:(BOOL)newHidden{
    [self.indicator stopAnimating];
    _indicatorHidden = newHidden;
}
- (void) generateNotifiesAndRefreshAfterWithText:(NSString*) text{
    /*[[[NVDataManager sharedManager] managedObjectContext] performBlock:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[NVNotificationManager sharedManager] generateNewNotificationsWithSemaphor:semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.indicatorHidden = YES;
            [self isDownloadEndWithText:text];
            self.navigationItem.leftBarButtonItem.title = @"Back";
        });
    }];*/
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[NVNotificationManager sharedManager] generateNewNotificationsWithSemaphor:semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.indicatorHidden = YES;
            [self isDownloadEndWithText:text];
            self.navigationItem.leftBarButtonItem.title = @"Back";
        });
        
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) isDownloadEndWithText:(NSString*) text {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    self.stringToSet = text;
    self.labelOfViewLoading.text = self.stringToSet;
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
