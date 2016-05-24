//
//  NVCreateNewDict.m
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVCreateNewDictVC.h"
#import "NVLangFromVC.h"
#import "NVLangToVC.h"
#import "NVServerManager.h"
#import "NVChooseDictThemeVC.h"
@interface NVCreateNewDictVC ()

@end

@implementation NVCreateNewDictVC
//@synthesize fetchedResultsController=_fetchedResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //ATTENTION! In viewDidAppear only, because if do it in viewDidLoad, then (NULL) will appear on screen, while new view controller is appearing.
    
    if (!self.dict) {
        self.managedObjectContext = [[NVDataManager sharedManager] managedObjectContext];
        NVDicts* newDict=[NSEntityDescription insertNewObjectForEntityForName:@"NVDicts" inManagedObjectContext:self.managedObjectContext];
        self.dict = newDict;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NVLangFromVCProtocol
-(void) refreshDataWithText:(NSString*) text shortLangFrom:(NSString*) shortLangFrom {
    self.textFieldLangFrom.text = text;
    self.langFromShort = shortLangFrom;
}

#pragma mark - NVLangToVCProtocol
-(void) refreshDataLangToWithText:(NSString*) text shortLangTo:(NSString*) shortLangTo {
    self.textFieldLangTo.text = text;
    self.langToShort = shortLangTo;
}

 #pragma mark - NVChooseThemeVCProtocol
-(void) refreshDataThemeWithTemplate:(NVTemplates*) templ{
    self.textFieldDictTheme.text = templ.name;
    self.templateForDict = templ;
}
 
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SegueLangFrom"]) {
        NVLangFromVC *vc = segue.destinationViewController;
        vc.delegate = self;
        if (![self.textFieldLangFrom.text isEqualToString:@""]) {
            vc.currentLang = self.textFieldLangFrom.text;
        }
    } else if ([segue.identifier isEqualToString:@"SegueLangTo"]){
        NVLangToVC *vc = segue.destinationViewController;
        vc.delegate = self;
        if (![self.textFieldLangTo.text isEqualToString:@""]) {
            vc.currentLang = self.textFieldLangTo.text;
        }
    } else if ([segue.identifier isEqualToString:@"SegueChooseDictTheme"]){
        NVChooseDictThemeVC *vc = segue.destinationViewController;
        vc.delegate = self;
        if (self.templateForDict) {
            vc.curTemplate = self.templateForDict;
        }
    }
}
- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [self.managedObjectContext rollback];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSave:(UIBarButtonItem *)sender {
    self.dict.from = self.textFieldLangFrom.text;
    self.dict.to = self.textFieldLangTo.text;
    self.dict.template1 = self.templateForDict;
    self.dict.progress = @(0);
    self.dict.isActive = @(false);
    self.dict.fromShort = self.langFromShort;
    self.dict.toShort = self.langToShort;

    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"error:%@",error.localizedDescription);
        NSLog(@"user info:%@",error.userInfo);
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - overriden methods
@end
