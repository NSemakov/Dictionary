//
//  NVChooseDictTheme.m
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVChooseDictThemeVC.h"

@interface NVChooseDictThemeVC ()

@end

@implementation NVChooseDictThemeVC
@synthesize fetchedResultsController=_fetchedResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContext.persistentStoreCoordinator = [[NVDataManager sharedManager] persistentStoreCoordinator];
    self.managedObjectContext = childContext;
}
- (void) viewWillAppear:(BOOL)animated {
    self.fetchedResultsController = nil;
    [self fetchedResultsController];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddOwnWords"]) {
        NVCreateTemplateVC* vc = segue.destinationViewController;
        vc.templateName = (NSString*) sender;
    } else if ([segue.identifier isEqualToString:@"segueStoreVC"]){
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - overriden methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NVTemplates *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = object.name;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curTemplate) {
       NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curTemplate];
        if (catIndex==indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } 
    }
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVTemplates" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"coursesAsStudent",@"coursesAsTeacher"]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //переопределяем, потому что не нужно сохранять контекст. Потенциально ведет к ошибке.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError* error;
        if (![context save:&error]) {
            NSLog(@"error:%@, locDesc:%@",error.userInfo,error.localizedDescription);
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curTemplate) {
        NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curTemplate];
        if (catIndex == indexPath.row) {
            return;
        }
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.curTemplate = [[sectionInfo objects]  objectAtIndex:indexPath.row];
    }
}

#pragma mark - actions

- (IBAction)buttonAddOwnWords:(UIBarButtonItem *)sender {
    NVChooseDictThemeVC* weakSelf = self;
    if ([UIAlertController class]){
        UIAlertController* alrtCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New list of words", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* okAction1=[UIAlertAction actionWithTitle:NSLocalizedString(@"Add own words",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf addOwnWordsAction];
        }];
        UIAlertAction* okAction2=[UIAlertAction actionWithTitle:NSLocalizedString(@"Buy ready lists",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf buyReadyListsAction];
        }];
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alrtCtrl addAction:okAction1];
        [alrtCtrl addAction:okAction2];
        [alrtCtrl addAction:cancelAction];
        [self presentViewController:alrtCtrl animated:YES completion:nil];
    } else {//ios 7 and lower
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"New list of words", nil) delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                NSLocalizedString(@"Add own words",nil),
                                NSLocalizedString(@"Buy ready lists",nil),
                                nil];
        popup.tag = 1;
        [popup showInView:self.view];
    }
}
#pragma mark - helpers
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self addOwnWordsAction];
                    break;
                case 1:
                    [self buyReadyListsAction];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
- (void) addOwnWordsAction{
    if ([UIAlertController class]){
        // ios 8 or higher
        self.alertCtrl=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Input template name", @"Input template name") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self.alertCtrl addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"New template name",@"New template name");
        }];
        __weak NVChooseDictThemeVC* weakSelf = self;
        UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField* field=weakSelf.alertCtrl.textFields.firstObject;
            //[self handleNameOfNewFolder:field.text];
            [self performSegueWithIdentifier:@"AddOwnWords" sender:field.text];
        }];
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.alertCtrl addAction:okAction];
        [self.alertCtrl addAction:cancelAction];
        [self presentViewController:self.alertCtrl animated:YES completion:nil];
    } else { //ios 7 and lower
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Input template name", @"Input template name") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}
- (void) buyReadyListsAction{
    [self performSegueWithIdentifier:@"segueStoreVC" sender:nil];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            break;
        }
        case 1:{
            NSString* name = [[alertView textFieldAtIndex:0] text];
            //[self handleNameOfNewFolder:field.text];
            [self performSegueWithIdentifier:@"AddOwnWords" sender:name];
        }
            break;
        default:
            break;
    }
    
}
- (IBAction)buttonOk:(UIBarButtonItem *)sender {
    [self.delegate refreshDataThemeWithTemplate:self.curTemplate];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
