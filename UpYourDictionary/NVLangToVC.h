//
//  NVLangToVC.h
//  
//
//  Created by Admin on 16/05/16.
//
//

#import "NVChooseLangVC.h"
@protocol NVLangToVCProtocol
-(void) refreshDataLangToWithText:(NSString*) text;
@end

@interface NVLangToVC : NVChooseLangVC
@property (strong,nonatomic) id<NVLangToVCProtocol> delegate;
@end
