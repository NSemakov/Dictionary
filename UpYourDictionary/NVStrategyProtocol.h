//
//  NVStrategyProtocol.h
//  UpYourDictionary
//
//  Created by Admin on 20/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NVDicts;
@class NVContent;
@protocol NVStrategyProtocol <NSObject>
@property (strong,nonatomic) NVDicts* activeDict;
-(NVContent*) algoResultHandler;
-(NVContent*) performAlgo;
-(void) pauseAlgo;
@end
