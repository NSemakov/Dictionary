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
    
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
}
- (void)setIndicatorHidden:(BOOL)newHidden{
    [self.indicator stopAnimating];
    _indicatorHidden = newHidden;
}
- (void) generateNotifiesAndRefreshAfterWithText:(NSString*) text withDict:(NVDicts*) dict sender:(id)sender {
    __weak NVContainerVC* weakSelf = self;
    __weak typeof(sender) weakSender = sender;
    [NVNotificationManager sharedManager].delegateToRefresh = weakSelf;
    //__weak NVContainerVC* weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        //dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[NVNotificationManager sharedManager] generateNewNotificationsForDict:dict withCallback:^(NSInteger counter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (counter == 0) {
                   if ([weakSender isKindOfClass:[NVChooseActiveDictVC class]]) {
                        [weakSelf isDownloadEndWithText:NSLocalizedString(@"Oops. It's look like translation server is unavailable. Please check your internet connection or if it's ok, give us one more chance little bit later", nil)];
                    } else if ([weakSender isKindOfClass:[NVSettingsVC class]]){
                        //из настроек допустимо, чтобы количество нотификаций было равно 0.
                        [weakSelf isDownloadEndWithText:text];
                    }
                } else if (counter > 0 && counter < 2) {//=1
                    //[weakSelf isDownloadEndWithText:NSLocalizedString(@"Oops. It's look like we can only partially prepare dictionary, cause translation server has become unavailable. Please check your internet connection or if it's ok, give us one more chance little bit later", nil)];
                } else {
                    [weakSelf isDownloadEndWithText:text];
                }
                weakSelf.indicatorHidden = YES;
                
                weakSelf.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Back", nil);
                //[NVNotificationManager sharedManager].delegateToRefresh = nil;
                });
        }];
    });
}
- (void) dealloc {
    //NSLog(@"dealloc NVContainerVC");
    //[NVNotificationManager sharedManager].delegateToRefresh = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (void) isDownloadEndWithText:(NSString*) text {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    self.stringToSet = text;
    self.labelOfViewLoading.text = self.stringToSet;
    self.progressView.hidden = YES;
}

-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
}
#pragma mark - actions
- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [NVNotificationManager sharedManager].delegateToRefresh = nil;
    [[NVNotificationManager sharedManager].queue cancelAllOperations];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
