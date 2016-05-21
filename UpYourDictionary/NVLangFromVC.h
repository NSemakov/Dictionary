//
//  NVLangFromVC.h
//  UpYourDictionary
//
//  Created by Admin on 16/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVChooseLangVC.h"
@protocol NVLangFromVCProtocol
-(void) refreshDataWithText:(NSString*) text shortLangFrom:(NSString*) shortLangFrom;
@end

@interface NVLangFromVC : NVChooseLangVC
@property (strong,nonatomic) id<NVLangFromVCProtocol> delegate;
@end
