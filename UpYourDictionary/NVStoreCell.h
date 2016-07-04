//
//  NVStoreCell.h
//  UpYourDictionary
//
//  Created by Admin on 01/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVButton.h"
@interface NVStoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
//@property (weak, nonatomic) IBOutlet UILabel *labelDownloadIsEnd;
@property (weak, nonatomic) IBOutlet UIProgressView *progressDownloading;

@property (weak, nonatomic) IBOutlet NVButton *buttonBuyOutlet;


@end
