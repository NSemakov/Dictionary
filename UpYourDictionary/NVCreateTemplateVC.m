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
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContext.parentContext = [[NVDataManager sharedManager] managedObjectContext] ;
    self.childContext = childContext;
    //use of child context
    self.managedObjectContext=[[NVDataManager sharedManager] managedObjectContext];
    //ATTENTION! In viewDidAppear only, because if do it in viewDidLoad, then (NULL) will appear on screen, while new view controller is appearing.
    NVTemplates* newTemplate=[NSEntityDescription insertNewObjectForEntityForName:@"NVTemplates" inManagedObjectContext:self.childContext];
    newTemplate.name = self.templateName;
    self.templateNew = newTemplate;
    NVWords* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.childContext];
    self.tempWordsSet = [NSMutableArray new];
    [self.tempWordsSet addObject:newWord];
    [self.tableView reloadData];
#warning  имя темплейту надо. при нажатии кнопки на предыдущем контроллере или здесь где-то поле
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.labelLeft.text =[NSString stringWithFormat:@"%d. Word:",indexPath.row+1];
    cell.textField.delegate = self;
    cell.textField.text = [[self.tempWordsSet objectAtIndex:indexPath.row] word];
    return cell;
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NVCreateTemplateCell* cell = [[textField superview] superview];
    NSIndexPath* indexPath =  [self.tableView indexPathForCell:cell];
    NVWords* word = [self.tempWordsSet objectAtIndex:indexPath.row];
    word.word = textField.text;
}
#pragma mark - Actions



- (IBAction)buttonAddWord:(UIBarButtonItem *)sender {
    NVWords* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.childContext];
    [self.tempWordsSet addObject:newWord];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.tempWordsSet count]-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
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
-(NSMutableArray*) validateWords{
    NSMutableArray* arrayOfWrongObjects = [NSMutableArray array];
    for (NVWords* word in self.tempWordsSet) {
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
    NSString* errorString = [NSString stringWithFormat:@"Words can't be empty. Please fill words in next rows: "];
    for (NSNumber *num in arrayOfWrongObjects) {
        NSString* stringToAdd = [NSString stringWithFormat:@" %@; ",num];
        errorString = [errorString stringByAppendingString:stringToAdd];
    }
    UIAlertController* alertCtrl=[UIAlertController alertControllerWithTitle:@"Attention" message:errorString preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertCtrl addAction:okAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}
- (IBAction)buttonCancel:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
     
@end
