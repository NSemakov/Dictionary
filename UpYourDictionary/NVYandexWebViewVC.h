//
//  NVYandexWebViewVC.h
//  UpYourDictionary
//
//  Created by Admin on 17/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVYandexWebViewVC : UIViewController <UIWebViewDelegate>
//
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)buttonClose:(UIBarButtonItem *)sender;

@end
