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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [super analogTableView:tableView didSelectRowAtIndexPath:indexPath];
    [self.delegate refreshDataLangToWithText:(self.currentLang) shortLangTo:self.currentShort];
}
/*
- (IBAction)buttonDone:(UIBarButtonItem *)sender {
    [self.delegate refreshDataLangToWithText:(self.currentLang) shortLangTo:self.currentShort];
    [self.navigationController popViewControllerAnimated:YES];
}
*/
@end
