//
//  NVCreateTemplateVC.m
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVCreateTemplateVC.h"

@interface NVCreateTemplateVC ()

@end

@implementation NVCreateTemplateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UIToolbar* toolbar = self.navigationController.toolbar;
    //[toolbar sizeToFit];
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationController.toolbar.frame = CGRectMake(0,
                                                         self.view.bounds.size.height - self.navigationController.toolbar.bounds.size.height,
                                                         self.navigationController.toolbar.bounds.size.width,
                                                         self.navigationController.toolbar.bounds.size.height);
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContext.persistentStoreCoordinator = [[NVDataManager sharedManager] persistentStoreCoordinator];
    //childContext.parentContext = [[NVDataManager sharedManager] managedObjectContext] ;
    self.childContext = childContext;
    //use of child context
    self.managedObjectContext=[[NVDataManager sharedManager] managedObjectContext];
    //ATTENTION! In viewDidAppear only, because if do it in viewDidLoad, then (NULL) will appear on screen, while new view controller is appearing.
    NVTemplates* newTemplate=[NSEntityDescription insertNewObjectForEntityForName:@"NVTemplates" inManagedObjectContext:self.childContext];
    newTemplate.name = self.templateName;
    self.templateNew = newTemplate;
    NVWords* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.childContext];
    newWord.word=@"";
    self.tempWordsSet = [NSMutableArray new];
    [self.tempWordsSet addObject:newWord];
    

    
    [self.tableView reloadData];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - keyboard notifications handlers
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    NSNumber *durationValue = info[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = info[UIKeyboardAnimationCurveUserInfoKey];
    NSValue *endFrame = info[UIKeyboardFrameEndUserInfoKey];
    
    [UIView animateWithDuration:durationValue.doubleValue
                          delay:0
                        options:(curveValue.intValue << 16)
                     animations:^{
                         self.navigationController.toolbar.frame = CGRectMake(0,
                                                                              [endFrame CGRectValue].origin.y - self.navigationController.toolbar.bounds.size.height,
                                                                              self.navigationController.toolbar.bounds.size.width,
                                                                              self.navigationController.toolbar.bounds.size.height);
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    NSNumber *durationValue = info[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = info[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:durationValue.doubleValue
                          delay:0
                        options:(curveValue.intValue << 16)
                     animations:^{
                         self.navigationController.toolbar.frame = CGRectMake(0,
                                                                              self.view.bounds.size.height - self.navigationController.toolbar.bounds.size.height,
                                                                              self.navigationController.toolbar.bounds.size.width,
                                                                              self.navigationController.toolbar.bounds.size.height);
                     }
                     completion:nil];
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [self.tempWordsSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier=@"Cell";
    NVCreateTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[NVCreateTemplateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* string1stPart = [NSString stringWithFormat:@"%ld. ",indexPath.row+1];
    NSString* string2ndPart = NSLocalizedString(@"Word:", @"word in russian");
    cell.labelLeft.text =[string1stPart stringByAppendingString:string2ndPart];
    cell.textField.delegate = self;
    cell.textField.text = (NSString*)[[self.tempWordsSet objectAtIndex:indexPath.row] word];
    UIColor *color = [UIColor whiteColor];
    
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Type your word", @"") attributes:@{NSForegroundColorAttributeName: color}];
    cell.textField.layer.borderColor=[[UIColor whiteColor]CGColor];
    cell.textField.layer.cornerRadius = 5;
    cell.textField.clipsToBounds = YES;
    cell.textField.layer.borderWidth=1.0;
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NVCommonManager setupFontsForView:cell andSubViews:YES];
    cell.backgroundColor = [UIColor clearColor];
}
#pragma mark - UITextFieldDelegate
/*- (void)textFieldDidEndEditing:(UITextField *)textField{
    NVCreateTemplateCell* cell = (NVCreateTemplateCell*)[[textField superview] superview];
    NSIndexPath* indexPath =  [self.tableView indexPathForCell:cell];
    NVWords* word = [self.tempWordsSet objectAtIndex:indexPath.row];
    word.word = textField.text;
}*/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    //NVCreateTemplateCell* cell = (NVCreateTemplateCell*)[[textField superview] superview];
    NVCreateTemplateCell* cell =(NVCreateTemplateCell*) [self GetCellFromTableView:self.tableView Sender:textField];
    NSIndexPath* indexPath =  [self.tableView indexPathForCell:cell];
    NVWords* word = [self.tempWordsSet objectAtIndex:indexPath.row];
    word.word = proposedNewString;

    return YES;
}
-(UITableViewCell*)GetCellFromTableView:(UITableView*)tableView Sender:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:pos];
    return [tableView cellForRowAtIndexPath:indexPath];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Actions



- (IBAction)buttonAddWord:(UIBarButtonItem *)sender {
    NVWords* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.childContext];
    newWord.word=@"";
    [self.tempWordsSet addObject:newWord];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.tempWordsSet count]-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    NVCreateTemplateCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
}

- (IBAction)buttonSaveTemplate:(UIButton *)sender {
    //проверка на пустоту и заполнение массива элементов с пустыми строками
    NSMutableArray* arrayOfWrongObjects = [self validateWords];
    if ([arrayOfWrongObjects count]==0)
    {
        [self prepareAndSaveContext:arrayOfWrongObjects];
        [self.navigationController popViewControllerAnimated:YES];
    } else
    {
        [self showWarning:arrayOfWrongObjects];
    }
}
- (IBAction)buttonCancel:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - helpers
-(NSMutableArray*) validateWords{
    NSMutableArray* arrayOfWrongObjects = [NSMutableArray array];
    for (NVWords* word in self.tempWordsSet) {
        NSLog(@"word: %@",word.word);
        NSInteger row = [self.tempWordsSet indexOfObject:word];
        //NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        if ([word.word isEqualToString:@""]) {
            [arrayOfWrongObjects addObject:@(row+1)];
        }
        /*NVCreateTemplateCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textField.text isEqualToString:@""]) {
            [arrayOfWrongObjects addObject:@(row+1)];
        } else{
            word.word = cell.textField.text;
        }*/
    }
    return arrayOfWrongObjects;
}
-(void) prepareAndSaveContext:(NSMutableArray*) arrayOfWrongObjects{
    [self.templateNew addWord:[NSSet setWithArray:self.tempWordsSet]];
    NSError* error = nil;
    
    if (![self.childContext save:&error]) {
        NSLog(@"error:%@",error.localizedDescription);
        NSLog(@"user info:%@",error.userInfo);
    }

}
-(void) showWarning:(NSMutableArray*) arrayOfWrongObjects{
    
    NSString* errorString = NSLocalizedString(@"Words can't be empty. Please fill words in next rows: ",@"");
    
    for (NSNumber *num in arrayOfWrongObjects) {
        NSString* stringToAdd = [NSString stringWithFormat:@" %@; ",num];
        errorString = [errorString stringByAppendingString:stringToAdd];
    }
    NSString* titleString = NSLocalizedString(@"Attention", @"attention");
    
    [self showAlertWithTitle:titleString message:errorString sender:self];
    
}
-(void) showAlertWithTitle:(NSString*) titleString message:(NSString*) messageString sender:(id) sender{
    if ([UIAlertController class]){
        // ios 8 or higher
        UIAlertController* alertCtrl=[UIAlertController alertControllerWithTitle: titleString message:messageString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil) style:UIAlertActionStyleDefault handler:nil];
        [alertCtrl addAction:okAction];
        [sender presentViewController:alertCtrl animated:YES completion:nil];
    } else { //ios 7 and lower
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:titleString message:messageString delegate:sender cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}


-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
}
@end
