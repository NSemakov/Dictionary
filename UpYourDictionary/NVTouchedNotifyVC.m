//
//  NVTouchedNotifyVC.m
//  UpYourDictionary
//
//  Created by Admin on 10/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVTouchedNotifyVC.h"

@interface NVTouchedNotifyVC ()

@end

@implementation NVTouchedNotifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    NSLog(@"NVTouchedNotifyVC");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrayOfWords count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* text = [self.arrayOfWords objectAtIndex:indexPath.row];
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                             @{ NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    
    //its not possible to get the cell label width since this method is called before cellForRow so best we can do
    //is get the table width and subtract the default extra space on either side of the label.
    CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 30, MAXFLOAT);
    
    CGRect rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    //Add back in the extra padding above and below label on table cell.
    rect.size.height = rect.size.height + 23;
    
    //if height is smaller than a normal row set it to the normal cell height, otherwise return the bigger dynamic height.
    return (rect.size.height < 44 ? 44 : rect.size.height);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NVTouchedNotifyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[NVTouchedNotifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.labelMain.text = [self.arrayOfWords objectAtIndex:indexPath.row];
    
    return cell;
}

-(void) refreshTableWithNotify:(UILocalNotification*) notify{
    if (!self.arrayOfWords) {
        self.arrayOfWords = [NSMutableArray new];
    }
    NVNotifyInUse* notifyInUse =[[NVNotificationManager sharedManager] fetchedNotifyWithDate:notify.fireDate];
    
    for (NVContent* content in notifyInUse.content) {
        //NSLog(@"content to cancel: %@, counter before: %@, fireDate:%@",content.word,content.counter,notifyInUse.fireDate);
        NSString* stringToShow = [NSString stringWithFormat:@"%@ - %@", content.word, content.translation];
        [self.arrayOfWords addObject:stringToShow];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.arrayOfWords count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
