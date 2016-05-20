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
#import "NVDataManager.h"
#import "NVTemplates.h"
#import "NVWords.h"
@interface NVMainStrategy : NSObject <NVStrategyProtocol>
@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong,nonatomic) NSArray*  fetchedDict;
@property (strong,nonatomic) NSArray*  fetchedContent;
@property (strong,nonatomic) NSArray*  fetchedAllowedWords;
@property (strong,nonatomic) NSArray*  fetchedWordsAllowedToShow;
@property (strong,nonatomic) NVDicts* activeDict;
@property (strong,nonatomic) NVDicts* activeTemplate;
-(void) performAlgo;
-(void) pauseAlgo;
@end
