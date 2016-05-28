//
//  NVLangFromVC.m
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVLangFromVC.h"

@interface NVLangFromVC ()

@end

@implementation NVLangFromVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonDone:(UIBarButtonItem *)sender {
    [self.delegate refreshDataWithText:(self.currentLang) shortLangFrom:self.currentShort];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
