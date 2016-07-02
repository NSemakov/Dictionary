//
//  NVContainerVC.m
//  UpYourDictionary
//
//  Created by Admin on 17/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVContainerVC.h"
#import "NVSettingsVC.h"
#import "NVChooseActiveDictVC.h"
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
- (void) generateNotifiesAndRefreshAfterWithText:(NSString*) text withDict:(NVDicts*) dict sender:(id)sender {
    __weak NVContainerVC* weakSelf = self;
    [NVNotificationManager sharedManager].delegateToRefresh = weakSelf;
    //__weak NVContainerVC* weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue/*dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{
        //dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[NVNotificationManager sharedManager] generateNewNotificationsForDict:dict withCallback:^(NSInteger counter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (counter == 0) {
                   if ([sender isKindOfClass:[NVChooseActiveDictVC class]]) {
                        [weakSelf isDownloadEndWithText:NSLocalizedString(@"Oops. It's look like translation server is unavailable. Please check your internet connection or if it's ok, give us one more chance little bit later", nil)];
                    } else if ([sender isKindOfClass:[NVSettingsVC class]]){
                        //из настроек допустимо, чтобы количество нотификаций было равно 0.
                        [weakSelf isDownloadEndWithText:text];
                    }
                } else if (counter > 0 && counter < 2) {//=1
                    /*[weakSelf isDownloadEndWithText:NSLocalizedString(@"Oops. It's look like we can only partially prepare dictionary, cause translation server has become unavailable. Please check your internet connection or if it's ok, give us one more chance little bit later", nil)];*/
                } else {
                    [weakSelf isDownloadEndWithText:text];
                }
                weakSelf.indicatorHidden = YES;
                
                weakSelf.navigationItem.leftBarButtonItem.title = @"Back";
                [NVNotificationManager sharedManager].delegateToRefresh = nil;
                });
        }];
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
