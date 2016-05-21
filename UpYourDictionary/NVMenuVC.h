//
//  NVMenuVC.h
//  UpYourDictionary
//
//  Created by Admin on 21/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVMainStrategy.h"
@interface NVMenuVC : UIViewController <NVMainStrategyProtocol>
- (IBAction)buttonTestAlgo:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTest;

@end
