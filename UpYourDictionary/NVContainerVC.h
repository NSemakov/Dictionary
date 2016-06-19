//
//  NVContainerVC.h
//  UpYourDictionary
//
//  Created by Admin on 17/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVNotificationManager.h"
#import "NVDataManager.h"
#import "NVMainStrategy.h"
@protocol NVNotificationManagerRefreshProgressBarProtocol;
@interface NVContainerVC : UIViewController <NVNotificationManagerRefreshProgressBarProtocol>

@property (weak, nonatomic) IBOutlet UILabel *labelOfViewLoading;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (assign, nonatomic) BOOL indicatorHidden;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonCancelProperty;
@property (strong, nonatomic) NSString* stringToSet;
- (IBAction)buttonCancel:(UIBarButtonItem *)sender;
- (void) isDownloadEndWithText:(NSString*) text;
- (void) generateNotifiesAndRefreshAfterWithText:(NSString*) text;
- (void)setIndicatorHidden:(BOOL)newHidden;
- (void) refreshProgressBar;
@end

