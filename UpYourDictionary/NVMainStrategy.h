//
//  NVMainStrategy.h
//  UpYourDictionary
//
//  Created by Admin on 20/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NVStrategyProtocol.h"
#import "NVContent.h"
#import "NVDicts.h"
#import "NVDataManager.h"
#import "NVServerManager.h"
#import "NVTemplates.h"
#import "NVWords.h"
#import "Constants.h"
//#import "NVContainerVC.h"

@protocol NVMainStrategyProtocol <NSObject>

-(void) showWord:(NSString*) word translation:(NSString*) translation;

@end

@interface NVMainStrategy : NSObject <NVStrategyProtocol>
@property (strong,nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong,nonatomic) NSArray*  fetchedDict;
@property (strong,nonatomic) NSArray*  fetchedContent;
@property (strong,nonatomic) NSArray*  fetchedAllowedWords;
@property (strong,nonatomic) NSArray*  fetchedWordsAllowedToShow;
@property (strong,nonatomic) NVDicts* activeDict;
@property (strong,nonatomic) NVTemplates* activeTemplate;
@property (strong,nonatomic) id <NVMainStrategyProtocol> delegate;
@property (assign,nonatomic) BOOL isYandexAvailable;
@property (strong, nonatomic) NSMutableSet* setOfTempTakenWords;
-(NVContent*) performAlgo;
- (NSInteger) countProgressOfDictionary;
- (void) pauseAlgo;
- (NVDicts*) activeDictByUser;
+(NVMainStrategy*) sharedManager;

@end
