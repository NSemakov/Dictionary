//
//  NVCreateNewDict.h
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NVChooseLangVCProtocol;
@interface NVCreateNewDictVC : UITableViewController <NVChooseLangVCProtocol>
@property (weak, nonatomic) IBOutlet UITextField *textFieldLangFrom;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLangTo;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDictTheme;
- (IBAction)buttonCancel:(UIButton *)sender;
- (IBAction)buttonSave:(UIButton *)sender;
-(void) refreshData:(NSString*) text;
@end
