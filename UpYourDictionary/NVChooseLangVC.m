//
//  NVChooseLangVC.m
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVChooseLangVC.h"
#import "NVServerManager.h"
@interface NVChooseLangVC ()
@property (strong,nonatomic) NSArray* dirs;
@property (strong,nonatomic) NSDictionary* langs;


@end

@implementation NVChooseLangVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.currentLang ){
        self.currentLang = @"";
    }
    
    __weak NVChooseLangVC* weakSelf = self;
    [[NVServerManager sharedManager] POSTListOfDirectionsOnSuccess:^(NSDictionary *responseObject) {
    weakSelf.langs = [responseObject objectForKey:@"langs"] ;
    weakSelf.dirs=[responseObject objectForKey:@"dirs"] ;
        [weakSelf.tableView reloadData];
    } onFailure:^(NSString *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.langs.count;
}
#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.langs allValues] objectAtIndex:indexPath.row];
    NSInteger catIndex = [[self.langs allValues] indexOfObject:self.currentLang];
    if (catIndex!= NSNotFound) {
        if (catIndex==indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger catIndex = [[self.langs allValues] indexOfObject:self.currentLang];
    if (catIndex == indexPath.row) {
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentLang = [[self.langs allValues] objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}



- (IBAction)buttonDone:(UIBarButtonItem *)sender {
    [self.delegate refreshData:(self.currentLang)];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
