//
//  NVMainStrategy.h
//  UpYourDictionary
//
//  Created by Admin on 20/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVStrategyProtocol.h"
#import "NVContent.h"
#import "NVDicts.h"
@interface NVMainStrategy : NSObject <NVStrategyProtocol>
-(void) performAlgo;
-(void) pauseAlgo;
@end
