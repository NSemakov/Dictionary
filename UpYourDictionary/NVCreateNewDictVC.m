//
//  NVCreateNewDict.m
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVCreateNewDictVC.h"

@interface NVCreateNewDictVC ()
@property (assign,nonatomic) BOOL isFieldFromCompleted;
@property (assign,nonatomic) BOOL isFieldToCompleted;
@property (assign,nonatomic) BOOL isFieldTemplateCompleted;
@end

@implementation NVCreateNewDictVC
//@synthesize fetchedResultsController=_fetchedResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFieldFromCompleted = NO;
    self.isFieldToCompleted = NO;
    self.isFieldTemplateCompleted = NO;
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
    if (shortLangFrom ) {
        self.textFieldLangFrom.text = text;
        self.langFromShort = shortLangFrom;
        UITableViewCell* cell = (UITableViewCell*)self.textFieldLangFrom.superview.superview;
        cell.backgroundColor = [self greenColor];
        self.isFieldFromCompleted = YES;
    }
}

#pragma mark - NVLangToVCProtocol
-(void) refreshDataLangToWithText:(NSString*) text shortLangTo:(NSString*) shortLangTo {
    if (shortLangTo) {
        self.textFieldLangTo.text = text;
        self.langToShort = shortLangTo;
        UITableViewCell* cell = (UITableViewCell*)self.textFieldLangTo.superview.superview;
        cell.backgroundColor = [self greenColor];
        self.isFieldToCompleted = YES;
    }
}

 #pragma mark - NVChooseThemeVCProtocol
-(void) refreshDataThemeWithTemplate:(NVTemplates*) templ{
    if (templ){
        self.templateForDict = [self fetchTemplateWithTemplate:templ];
        self.textFieldDictTheme.text = templ.name;
        UITableViewCell* cell = (UITableViewCell*)self.textFieldDictTheme.superview.superview;
        cell.backgroundColor = [self greenColor];
        self.isFieldTemplateCompleted = YES;
    }
    //self.templateForDict = templ;
}

-(UIColor*) greenColor{
    return [UIColor colorWithRed:(124/255.f) green:232/255.f blue:136/255.f alpha:1];
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

- (IBAction)buttonSave:(UIBarButtonItem *)sender {
    //check for filled filds
    if (self.isFieldFromCompleted && self.isFieldToCompleted && self.isFieldTemplateCompleted) {
        self.dict.from = self.textFieldLangFrom.text;
        self.dict.to = self.textFieldLangTo.text;
        //self.dict.template1 = [self.managedObjectContext objectWithID:[self.templateForDict objectID]];
        self.dict.template1 = self.templateForDict;
        self.dict.progress = @(0);
        self.dict.isActive = @(false);
        self.dict.fromShort = self.langFromShort;
        self.dict.toShort = self.langToShort;
        if (!self.dict.template1.lang) {//если язык шаблона не установлен, значит был создан новый шаблон и ему выставляется язык, который был выбран в поле from
            self.dict.template1.lang = self.dict.from;
            self.dict.template1.langShort=self.dict.fromShort;
        }
        
        
        NSError* error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"error:%@",error.localizedDescription);
            NSLog(@"user info:%@",error.userInfo);
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }

    } else {
        [self showWarningMessage];
    }
    
}

- (IBAction)actionBackButton:(UIBarButtonItem *)sender {
    
    [self.managedObjectContext rollback];
    [NSThread sleepForTimeInterval:.5];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - helpers
- (NVTemplates*) fetchTemplateWithTemplate:(NVTemplates*) template{
    NSManagedObjectID* objectID = [template objectID];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVTemplates" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(SELF = %@)",objectID];
    [fetchRequest setPredicate:predicate];

    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if ([resultArray count]) {
            return [resultArray firstObject];
        }
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
    return nil;
}
-(void) showWarningMessage{
    if ([UIAlertController class]){
        // ios 8 or higher
        UIAlertController* alertCtrl=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please write in all fields", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        /*
         UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
         */
        [alertCtrl addAction:okAction];
        //[self.alertCtrl addAction:cancelAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    } else { //ios 7 and lower
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please write in all fields", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }

}
@end
