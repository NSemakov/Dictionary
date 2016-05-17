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
    childContext.parentContext = self.managedObjectContext ;
    self.childContext = childContext;
    //use of child context
    
    //ATTENTION! In viewDidAppear only, because if do it in viewDidLoad, then (NULL) will appear on screen, while new view controller is appearing.
    NVTemplates* newTemplate=[NSEntityDescription insertNewObjectForEntityForName:@"NVTemplates" inManagedObjectContext:self.childContext];
    self.templateNew = newTemplate;
    NVWords* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.childContext];
    self.tempWordsSet = [NSMutableSet new];
    [self.tempWordsSet addObject:newWord];
#warning  имя темплейту надо. при нажатии кнопки на предыдущем контроллере или здесь где-то поле
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonAddWord:(UIBarButtonItem *)sender {
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[self.tempWordsSet count] inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    NVWords* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.childContext];
    [self.tempWordsSet addObject:newWord];
}

- (IBAction)buttonSaveTemplate:(UIButton *)sender {
    self.templateNew.word=self.tempWordsSet;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonCancel:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
     
@end
