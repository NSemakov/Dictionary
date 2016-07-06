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
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.isFieldFromCompleted = NO;
    
    self.isFieldToCompleted = NO;
    self.isFieldTemplateCompleted = NO;
    // Do any additional setup after loading the view.
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
    [NVCommonManager setupFontsForView:[[self.textFieldDictTheme superview] superview] andSubViews:YES];
    [NVCommonManager setupFontsForView:[[self.textFieldLangFrom superview] superview] andSubViews:YES];
    [NVCommonManager setupFontsForView:[[self.textFieldLangTo superview] superview] andSubViews:YES];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        return UITableViewAutomaticDimension;
    }
    CGFloat height = 0;
    
    /*1.*/
    height = height + [NVCommonManager heightForOneLabel:@"Language   from" width:CGRectGetWidth(tableView.bounds)];
    /*2.*/
    height = height + [NVCommonManager heightForOneLabel:@"Language   from" width:CGRectGetWidth(tableView.bounds)];
    
    return (height < 44 ? 44 : height);
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
    if ([self checkForCompletionAllFields]) {
        [self saveNewDictionary];
    } else {
        [self showWarningMessage];
    }
}

- (IBAction)actionBackButton:(UIBarButtonItem *)sender {
    if ([self checkForCompletionAllFields]) {
        [self askIfCancelOrSave];
    } else {
        [self.managedObjectContext rollback];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            [self.managedObjectContext rollback];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:{
            [self saveNewDictionary];
        }
            break;
        default:
            break;
    }
    
}
#pragma mark - helpers
- (void) askIfCancelOrSave{
    if ([UIAlertController class]){
        // ios 8 or higher
        UIAlertController *alertCtrl=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel without saving?", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Save",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self saveNewDictionary];
        }];
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel all changes",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.managedObjectContext rollback];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertCtrl addAction:okAction];
        [alertCtrl addAction:cancelAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    } else { //ios 7 and lower
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Cancel without saving?", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Save",nil), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

- (BOOL) checkForCompletionAllFields{
    return self.isFieldFromCompleted && self.isFieldToCompleted && self.isFieldTemplateCompleted;
}
- (void) saveNewDictionary{
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
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}
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
        [alertCtrl addAction:okAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    } else { //ios 7 and lower
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please write in all fields", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
}
@end
