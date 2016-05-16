//
//  NVChooseLangVC.h
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NVChooseLangVCProtocol
-(void) refreshData:(NSString*) text;
@end
@interface NVChooseLangVC : UITableViewController 
- (IBAction)buttonDone:(UIBarButtonItem *)sender;
@property (strong,nonatomic) id<NVChooseLangVCProtocol> delegate;
@property (strong,nonatomic) NSString* currentLang;
@end
