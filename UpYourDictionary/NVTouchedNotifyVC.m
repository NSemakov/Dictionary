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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.arrayOfWords objectAtIndex:indexPath.row];
    
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


@end
