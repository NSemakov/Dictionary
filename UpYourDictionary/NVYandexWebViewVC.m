//
//  NVYandexWebViewVC.m
//  UpYourDictionary
//
//  Created by Admin on 17/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVYandexWebViewVC.h"

@interface NVYandexWebViewVC ()

@end

@implementation NVYandexWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL* urlRelative=[NSURL URLWithString:@"https://"];
    NSURL* url=[NSURL URLWithString:@"translate.yandex.com/" relativeToURL:urlRelative];
    
    NSURLRequest* request=[NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
- (void)webViewDidStartLoad:(UIWebView *)webView{

    [self.activityIndicator startAnimating];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicator stopAnimating];
}
#pragma mark - actions
- (IBAction)buttonClose:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
