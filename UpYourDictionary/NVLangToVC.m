//
//  NVLangToVC.m
//  
//
//  Created by Admin on 16/05/16.
//
//

#import "NVLangToVC.h"

@interface NVLangToVC ()

@end

@implementation NVLangToVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonDone:(UIBarButtonItem *)sender {
    [self.delegate refreshDataLangToWithText:(self.currentLang)];
    [self.navigationController popViewControllerAnimated:YES];
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
