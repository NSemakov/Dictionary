//
//  NVChooseActiveDictVC.m
//  UpYourDictionary
//
//  Created by Admin on 17/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVChooseActiveDictVC.h"

@interface NVChooseActiveDictVC ()

@end

@implementation NVChooseActiveDictVC
@synthesize fetchedResultsController=_fetchedResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


#pragma mark - overriden methods 
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NVDicts *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([object.isActive boolValue]) {
        self.activeDict = object;
        self.curDict = object;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",object.template1.name,object.from,object.to,object.progress];
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curDict) {
        NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curDict];
        if (catIndex==indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

#warning pay attention
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curDict) {
        NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curDict];
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
        self.curDict = [[sectionInfo objects]  objectAtIndex:indexPath.row];
    }
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
#warning entity name override!
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVDicts" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"coursesAsStudent",@"coursesAsTeacher"]];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"template1.name" ascending:YES];
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
#pragma mark - actions
- (IBAction)buttonAdd:(UIBarButtonItem *)sender {
}

- (IBAction)buttonSave:(UIBarButtonItem *)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curDict && self.activeDict) {
        if ([self.curDict isEqual:self.activeDict]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.curDict.isActive = @(true);
            self.activeDict.isActive = @(false);
            NSError* error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"error: %@, user info: %@", error.localizedDescription,error.userInfo);
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else if (self.curDict && !self.activeDict){
        self.curDict.isActive = @(true);
        NSError* error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"error: %@, user info: %@", error.localizedDescription,error.userInfo);
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    
}
@end
