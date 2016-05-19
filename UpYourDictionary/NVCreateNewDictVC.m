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
-(void) refreshDataWithText:(NSString*) text {
    self.textFieldLangFrom.text = text;
}
#pragma mark - NVLangToVCProtocol
-(void) refreshDataLangToWithText:(NSString*) text {
    self.textFieldLangTo.text = text;
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
#warning check all fields!
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"error:%@",error.localizedDescription);
        NSLog(@"user info:%@",error.userInfo);
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - overriden methods
/*
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVDicts" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"coursesAsStudent",@"coursesAsTeacher"]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"from" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //NSManagedObjectID *moID=[self.person objectID];
    //NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(SELF = %@)",self.person];
    //[fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}
 */
@end
