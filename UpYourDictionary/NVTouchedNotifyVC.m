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
    
    //yandex button with dynamic font size
    UIButton *myButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [myButton setTitle:NSLocalizedString(@"Powered by Yandex.Translate", nil) forState:UIControlStateNormal];
    [myButton setFrame: CGRectMake(0, 0, 300, self.navigationController.toolbar.frame.size.height)];
    
    [myButton.titleLabel setFont: [UIFont boldSystemFontOfSize:100.0]];
    [myButton addTarget:self action:@selector(buttonYandexSender:) forControlEvents:UIControlEventTouchUpInside];
    myButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    myButton.titleLabel.minimumScaleFactor = 0.05;
    myButton.titleLabel.numberOfLines = 1;
    myButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    myButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    myButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithCustomView:myButton];
    UIBarButtonItem *buttonLeftFlex = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonRightFlex = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[buttonLeftFlex, button, buttonRightFlex] animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - helpers 
-(void) buttonYandexSender:(UIButton*) sender {
    [self performSegueWithIdentifier:@"segueYandexVC" sender:sender];
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
