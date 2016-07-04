//
//  NVStoreVC.m
//  UpYourDictionary
//
//  Created by Admin on 30/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVStoreVC.h"

@interface NVStoreVC ()

@end

@implementation NVStoreVC {
    //NSArray *_products;
    BOOL _productsRequestFinished;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Store", @"");
    [[RMStore defaultStore]addStoreObserver:self];

#warning Replace with your product ids.
    /*_products = @[@"net.robotmedia.test.consumable",
                  @"net.robotmedia.test.nonconsumable",
                  @"net.robotmedia.test.nonconsumable.2"];
    */
    _products = [RMStore defaultStore].productIdentifiers;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak NVStoreVC* weakSelf = self;
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:_products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _productsRequestFinished = YES;
        //weakSelf.products = products;
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        if ([UIAlertController class]) {
            UIAlertController* alertCtrl=[UIAlertController alertControllerWithTitle: NSLocalizedString(@"Products Request Failed", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction* okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil];
            [alertCtrl addAction:okAction];
            [self presentViewController:alertCtrl animated:YES completion:nil];
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
    self.tableView.allowsSelection = NO;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self.tableView];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
}

#pragma mark - RMStoreObserver
- (void)storeDownloadFinished:(NSNotification*)notification{
    NSString* path =  [notification.rm_storeDownload.contentURL path];
    path = [path stringByAppendingPathComponent:@"Contents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    NSString *fullPathSrc = [path stringByAppendingPathComponent:[files firstObject]];
    
    NSString *productID = notification.rm_storeDownload.contentIdentifier;
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    BOOL success = [self addNewTemplate:fullPathSrc templateName:product.localizedTitle langShort:@"en" productID:productID];
    NVStoreCell* cell = [self cellForProductIDFromNotification:notification];
    cell.progressDownloading.hidden = YES;
    //cell.labelDownloadIsEnd.hidden = NO;
    if (!success) {//все добавлено в базу
        //cell.labelDownloadIsEnd.text = @"Error in processing content";
    } else {
        [cell.buttonBuyOutlet setTitle:NSLocalizedString(@"Purchased!", nil) forState:UIControlStateNormal];
        cell.buttonBuyOutlet.enabled = NO;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[productID stringByAppendingString:NVPostFixThatAddedToShowThisIsContent]];

    
}
- (void)storeDownloadUpdated:(NSNotification*)notification {
    
    float progress =  notification.rm_downloadProgress;
    NVStoreCell* cell = [self cellForProductIDFromNotification:notification];
    cell.progressDownloading.hidden = NO;
    cell.progressDownloading.progress = progress;
    
}
-(void)storeRestoreTransactionsFinished:(NSNotification *)notification{
    NSString* titleString = NSLocalizedString(@"Purchased items have been successfully restored", @"");
    NSString* messageString = nil;
    [self showAlertWithTitle:titleString message:messageString sender:self];
}
-(void)storeRestoreTransactionsFailed:(NSNotification *)notification{
    [self showAlertWithTitle:NSLocalizedString(@"Restore Transactions Failed", @"") message:notification.rm_storeError.localizedDescription sender:self];
}

#pragma mark - helpers

- (NVStoreCell*) cellForProductIDFromNotification:(NSNotification*) notification {
    NSString *productID = notification.rm_productIdentifier;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_products indexOfObject:productID] inSection:0];
    return [self.tableView cellForRowAtIndexPath:indexPath];
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
- (void) buttonBuyCustomAction:(NVButton*) button {

    if (![RMStore canMakePayments]) return;
    
    NSString *productID = button.userData;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productID];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if ([UIAlertController class]) {
            UIAlertController* alertCtrl=[UIAlertController alertControllerWithTitle: NSLocalizedString(@"Payment Transaction Failed", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil];
            [alertCtrl addAction:okAction];
            [self presentViewController:alertCtrl animated:YES completion:nil];
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                     otherButtonTitles:nil];
            [alerView show];
        }
    }];
}

-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _productsRequestFinished ? _products.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NVStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.buttonBuyOutlet addTarget:self action:@selector(buttonBuyCustomAction:) forControlEvents:UIControlEventTouchUpInside];

    NSString *productID = _products[indexPath.row];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    cell.labelTitle.text = [[product.localizedTitle stringByAppendingString:@". "] stringByAppendingString:product.localizedDescription];
    cell.labelPrice.text = [RMStore localizedPriceOfProduct:product];
    cell.buttonBuyOutlet.userData = productID;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:productID]) {
        [cell.buttonBuyOutlet setTitle:NSLocalizedString(@"Purchased!", nil) forState:UIControlStateNormal];
        cell.buttonBuyOutlet.enabled = NO;
    }
    [NVCommonManager setupFontsForView:cell andSubViews:YES];
    [cell layoutIfNeeded];
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.backgroundColor = [UIColor clearColor];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        return UITableViewAutomaticDimension;
    }
    CGFloat height = 0;
    NSString *productID = _products[indexPath.row];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    /*1.*/
    NSString* text = [[product.localizedTitle stringByAppendingString:@". "] stringByAppendingString:product.localizedDescription];
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                             @{ NSFontAttributeName: [NVCommonManager getReadyFont]}];
    
    //its not possible to get the cell label width since this method is called before cellForRow so best we can do
    //is get the table width and subtract the default extra space on either side of the label.
    CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 130, MAXFLOAT);
    CGRect rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    //Add back in the extra padding above and below label on table cell.
    height = rect.size.height;
    /*2.*/
    text = [RMStore localizedPriceOfProduct:product];
     attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                        @{ NSFontAttributeName: [NVCommonManager getReadyFont]}];
    constraintSize = CGSizeMake(tableView.frame.size.width - 130, MAXFLOAT);
    rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    //Add back in the extra padding above and below label on table cell.
    rect.size.height = rect.size.height + 50;
    height = height + rect.size.height;
    //if height is smaller than a normal row set it to the normal cell height, otherwise return the bigger dynamic height.
    return (height < 44 ? 44 : height);
}

- (BOOL) addNewTemplate:(NSString*)dataPath templateName:(NSString*)templateName langShort:(NSString*) langShort productID:(NSString*) productID{
    NSError* err = nil;
    NSString *string = [[NSString alloc] initWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&err];
    //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray* clearArray = [NSMutableArray new];
    for (NSString* str in array) {
        if (![str isEqualToString:@""]) {
            [clearArray addObject:str];
        }
    }
    //NSLog(@"%@, errorUserIfo: %@\n errorDescr: %@",array, err.userInfo,err.description);
    /*for (NSString* str in clearArray){
        NSLog(@"%@",str);
    }*/
    return [[NVDataManager sharedManager] addDataToDb:clearArray withName:templateName langShort:langShort productID:productID];
}

-(void)dealloc{
    [[RMStore defaultStore]removeStoreObserver:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark - actions
- (IBAction)buttonRestorePurchases:(UIBarButtonItem *)sender {
    NSArray* arrayOfProductIds = [[NVDataManager sharedManager] fetchTemplatesForNonNilProductIds];
    [[RMStore defaultStore] restoreTransactionsBySkipReDownloadProductID:arrayOfProductIds OnSuccess:nil failure:nil];
}

@end
