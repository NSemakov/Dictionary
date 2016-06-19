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
    self.progressView.progress=0.1f;
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
    __weak NVContainerVC* weakSelf = self;
    [NVNotificationManager sharedManager].delegateToRefresh = weakSelf;
    //__weak NVContainerVC* weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue/*dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{
        //dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[NVNotificationManager sharedManager] generateNewNotificationsWithCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.indicatorHidden = YES;
                [weakSelf isDownloadEndWithText:text];
                weakSelf.navigationItem.leftBarButtonItem.title = @"Back";
                [NVNotificationManager sharedManager].delegateToRefresh = nil;
            });
        }];
        //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        /*dispatch_async(dispatch_get_main_queue(), ^{
            self.indicatorHidden = YES;
            [self isDownloadEndWithText:text];
            self.navigationItem.leftBarButtonItem.title = @"Back";
        });*/
        
    });
}
- (void) dealloc {
    [NVNotificationManager sharedManager].delegateToRefresh = nil;
}
- (void) refreshProgressBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = self.progressView.progress + 90.f/61.f/100.f;
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
    self.progressView.hidden = YES;
}

@end
