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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
#pragma mark - when download finished
- (void)storeDownloadFinished:(NSNotification*)notification{
    NSString* path =  [notification.rm_storeDownload.contentURL path];
    path = [path stringByAppendingPathComponent:@"Contents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    NSString *fullPathSrc = [path stringByAppendingPathComponent:[files firstObject]];
    
    NSString *productID = notification.rm_storeDownload.contentIdentifier;
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    [self addNewTemplate:fullPathSrc templateName:[product.localizedTitle stringByAppendingString:@"222"] langShort:@"en"];
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
    /*if (cell == nil)
    {
        cell = [[NVStoreCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }*/
    NSString *productID = _products[indexPath.row];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    cell.labelTitle.text = [[product.localizedTitle stringByAppendingString:@". "] stringByAppendingString:product.localizedDescription];
    cell.labelPrice.text = [RMStore localizedPriceOfProduct:product];
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![RMStore canMakePayments]) return;
    
    NSString *productID = _products[indexPath.row];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
        [alerView show];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    NSString *productID = _products[indexPath.row];
    SKProduct *product = [[RMStore defaultStore] productForIdentifier:productID];
    /*1.*/
    NSString* text = [[product.localizedTitle stringByAppendingString:@". "] stringByAppendingString:product.localizedDescription];

    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                             @{ NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    
    //its not possible to get the cell label width since this method is called before cellForRow so best we can do
    //is get the table width and subtract the default extra space on either side of the label.
    CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 30, MAXFLOAT);
    
    CGRect rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    //Add back in the extra padding above and below label on table cell.
    height = rect.size.height;
    /*2.*/
    text = [RMStore localizedPriceOfProduct:product];
     attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                             @{ NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    
    //its not possible to get the cell label width since this method is called before cellForRow so best we can do
    //is get the table width and subtract the default extra space on either side of the label.
    constraintSize = CGSizeMake(tableView.frame.size.width - 30, MAXFLOAT);
    
    rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    //Add back in the extra padding above and below label on table cell.
    rect.size.height = rect.size.height + 30;
    height = height + rect.size.height;
    //if height is smaller than a normal row set it to the normal cell height, otherwise return the bigger dynamic height.
    return (height < 44 ? 44 : height);
}

- (void) addNewTemplate:(NSString*)dataPath templateName:(NSString*)templateName langShort:(NSString*) langShort {
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
    for (NSString* str in clearArray){
        NSLog(@"%@",str);
    }
    [[NVDataManager sharedManager] addDataToDb:clearArray withName:templateName langShort:langShort];

}

-(void)dealloc{
    [[RMStore defaultStore]removeStoreObserver:self];
}
@end
