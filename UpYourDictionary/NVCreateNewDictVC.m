//
//  NVCreateNewDict.m
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVCreateNewDictVC.h"
#import "NVChooseLangVC.h"
#import "NVServerManager.h"
@interface NVCreateNewDictVC ()

@end

@implementation NVCreateNewDictVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - NVChooseLangVCProtocol
-(void) refreshData:(NSString*) text {
    self.textFieldLangFrom.text = text;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueLangFrom"]) {
        NVChooseLangVC *vc = segue.destinationViewController;
        vc.delegate = self;
        if (![self.textFieldLangFrom.text isEqualToString:@""]) {
            vc.currentLang = self.textFieldLangFrom.text;
        }
        
    } else if ([segue.identifier isEqualToString:@"SegueLangTo"]){
        NVChooseLangVC *vc = segue.destinationViewController;
    }
    
    
}


- (IBAction)buttonCancel:(UIButton *)sender {
}

- (IBAction)buttonSave:(UIButton *)sender {
}
@end
