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
    self.tableView.allowsSelection = NO;
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
    
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - helpers 
-(void) buttonYandexSender:(UIButton*) sender {
    [self performSegueWithIdentifier:@"segueYandexVC" sender:sender];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.tableView andSubViews:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrayOfWords count];
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
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NVCommonManager setupFontsForView:cell andSubViews:YES];
    cell.backgroundColor = [UIColor clearColor];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        return UITableViewAutomaticDimension;
    }
    CGFloat height = 0;
    
    /*1.*/
    height = height + [NVCommonManager heightForOneLabel:[self.arrayOfWords objectAtIndex:indexPath.row] width:CGRectGetWidth(tableView.bounds)];
    
    return (height < 44 ? 44 : height);
}
#pragma mark - actions
- (IBAction)buttonCancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
