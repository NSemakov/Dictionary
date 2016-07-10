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
//@synthesize managedObjectContext=_managedObjectContext;
//- (UITableView*)tableView { return self.tableViewReference; }
//- (UIView*)view { return self.viewReference; }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // instantiate the new self.view, similar to the tableview
/*    self.viewReference = [[UIView alloc] initWithFrame:self.tableViewReference.frame];
    [self.viewReference setBackgroundColor:self.tableViewReference.backgroundColor];
    self.viewReference.autoresizingMask = self.tableViewReference.autoresizingMask;
    // add it as a subview
    [self.viewReference addSubview:self.tableViewReference];
*/
    /* remainder of viewDidLoad */
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overriden methods
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NVChooseActiveDictCell* cellMain = (NVChooseActiveDictCell*) cell;
    cellMain.accessoryType = UITableViewCellAccessoryNone;
    NVDicts *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([object.isActive boolValue]) {
        self.activeDict = object;
        self.curDict = object;
    }
    cellMain.labelTheme.text = [NSString stringWithFormat:NSLocalizedString(@"Theme: %@", nil), object.template1.name];
    cellMain.labelLangFrom.text = [NSString stringWithFormat:NSLocalizedString(@"From: %@", nil), object.from];
    cellMain.labelLangTo.text = [NSString stringWithFormat:NSLocalizedString(@"To: %@", nil), object.to];
    cellMain.labelProgress.text = [NSString stringWithFormat:NSLocalizedString(@"Progress: %@ %%", nil), object.progress];
    //cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",object.template1.name,object.from,object.to,object.progress];
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curDict) {
        NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curDict];
        if (catIndex==indexPath.row) {
            cellMain.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        NVDicts *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([object.isActive boolValue]) {
            self.activeDict = nil;
            self.curDict = nil;
            object.isActive = @(NO);
            
        }
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            [[NVNotificationManager sharedManager] cancelNotificationsCompleteWayWithCallback:nil];
        }
    }
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curDict) {
        NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curDict];
        
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (catIndex == indexPath.row) {
            self.curDict=nil;
            return;
        }
    }
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.curDict = [[sectionInfo objects]  objectAtIndex:indexPath.row];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        return UITableViewAutomaticDimension;
    }
    CGFloat height = 0;
    NVDicts *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    /*1.*/
    height = height + [NVCommonManager heightForOneLabel:[NSString stringWithFormat:NSLocalizedString(@"Theme: %@", nil), object.template1.name] width:CGRectGetWidth(tableView.bounds)];
    /*2.*/
    height = height + [NVCommonManager heightForOneLabel:[NSString stringWithFormat:NSLocalizedString(@"From: %@", nil), object.from] width:CGRectGetWidth(tableView.bounds)];
    /*3.*/
    height = height + [NVCommonManager heightForOneLabel:[NSString stringWithFormat:NSLocalizedString(@"To: %@", nil), object.to] width:CGRectGetWidth(tableView.bounds)];
    /*4.*/
    height = height + [NVCommonManager heightForOneLabel:[NSString stringWithFormat:NSLocalizedString(@"Progress: %@ %%", nil), object.progress] width:CGRectGetWidth(tableView.bounds)];
    
    return (height < 44 ? 44 : height - 110);
}

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
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:{
            [self buttonSave:nil];
        }
            break;
        default:
            break;
    }
    
}
#pragma mark - helpers
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueShowDownLoadingScreen"]) {
        NVContainerVC* vc = segue.destinationViewController;
        vc.stringToSet = NSLocalizedString(@"Preparing dictionary for first use. Please wait about 20 sec. On success this message will disapper.", nil);
        self.loadingVC = vc;
    }
}
- (void) askIfCancelOrSave{
    if ([UIAlertController class]){
        // ios 8 or higher
        UIAlertController *alertCtrl=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"Cancel without saving?", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Save",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self buttonSave:nil];
        }];
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertCtrl addAction:okAction];
        [alertCtrl addAction:cancelAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    } else { //ios 7 and lower
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Cancel without saving?", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Save",nil), nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}
#pragma mark - actions
- (IBAction)buttonAdd:(UIBarButtonItem *)sender {
    
}

- (IBAction)buttonSave:(UIBarButtonItem *)sender {

    //save dictionary as active
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    
    
    if (self.curDict && self.activeDict) {
        if ([self.curDict isEqual:self.activeDict]) {
            //nothing. ничего не изменилось.
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.curDict.isActive = @(true);
            self.activeDict.isActive = @(false);
            //save context
            NSError* error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"error buttonSave: %@, user info: %@", error.localizedDescription,error.userInfo);
            } else {
                [self performSegueWithIdentifier:@"segueShowDownLoadingScreen" sender:nil];
                [self.loadingVC generateNotifiesAndRefreshAfterWithText:NSLocalizedString(@"Preparing is done! Now you can push app to background and just read arriving notification with translation.", nil) withDict:self.curDict sender:self];
               // [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else if (self.curDict && !self.activeDict){//не было активного словаря, ставим галочку в первый раз
        self.curDict.isActive = @(true);
        //save context
        
        NSError* error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"error buttonSave: %@, user info: %@", error.localizedDescription,error.userInfo);
        } else {
            [self performSegueWithIdentifier:@"segueShowDownLoadingScreen" sender:nil];

            [self.loadingVC generateNotifiesAndRefreshAfterWithText:NSLocalizedString(@"Preparing is done! Now you can push app to background and just read arriving notification with translation.", nil) withDict:self.curDict sender:self];
            //[self.navigationController popViewControllerAnimated:YES];
        }
    } else if (!self.curDict && self.activeDict){//был активный словарь, активность сняли
        self.activeDict.isActive=@(false);
        //[[NVNotificationManager sharedManager] cancelNotificationsCompleteWayWithCallback:nil];
        //save context
        NSError* error = nil;
         NSLog(@"lanf from %@, lang to %@", self.activeDict.fromShort,self.activeDict.toShort);
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"error buttonSave: %@, user info: %@", error.localizedDescription,error.userInfo);
        } else {
            //cancel local notifications in background
            //dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_CONCURRENT);
             //dispatch_async(queue, ^{
                 [[NVNotificationManager sharedManager] cancelNotificationsCompleteWayWithCallback:^{
                     NSLog(@"lanf from %@, lang to %@", self.activeDict.fromShort,self.activeDict.toShort);
                 }];
             //});
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    

}

- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    if (![self.curDict isEqual:self.activeDict]) {//smth has changed
        [self askIfCancelOrSave];
        
    } else {
       [self.managedObjectContext rollback];
       [self.navigationController popViewControllerAnimated:YES]; 
    }
    
}

- (IBAction)buttonDisableChoise:(UIBarButtonItem *)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    if (self.curDict) {
        NSInteger catIndex = [[sectionInfo objects] indexOfObject:self.curDict];
        
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        self.curDict=nil;
    }
}

/*- (NSManagedObjectContext*) managedObjectContext{
    if (!_managedObjectContext) {
        _managedObjectContext=[[NVDataManager sharedManager] privateManagedObjectContext];
        
    }
    return _managedObjectContext;
}*/
@end
