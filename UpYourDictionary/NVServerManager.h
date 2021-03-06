//
//  NVServerManager.h
//  45. APIWithoutAccessToken
//
//  Created by Admin on 28.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SystemConfiguration/SCNetworkReachability.h>
#import "Constants.h"
@class FIRDatabaseReference;
@class AFHTTPSessionManager;
@interface NVServerManager : NSObject
@property (strong,nonatomic) NSString* APIDictKey;
@property (strong,nonatomic) NSString* APITranslatorKey;
@property (strong,nonatomic) AFHTTPSessionManager* manager;
@property (strong,nonatomic) FIRDatabaseReference* remoteDB;
+(NVServerManager*) sharedManager;
- (BOOL) isNetworkAvailable;
-(void) POSTListOfDirectionsOnLang:(NSString*) lang OnSuccess:(void(^)(NSDictionary* languages)) onSuccess
                         onFailure:(void(^)(NSString* error)) onFailure;
-(void) POSTTranslatePhrase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess onFailure:(void(^)(NSString* error)) onFailure;
-(void) POSTLookUpDictionary:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                   onFailure:(void(^)(NSString* error)) onFailure;
-(void) POSTSearchInCachedWordsAtFirebase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                   onFailure:(void(^)(NSString* error)) onFailure;
-(void) POSTAddToCachedWordsAtFirebase:(NSString*) phrase translation:(NSString*) translation fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                             onFailure:(void(^)(NSString* error)) onFailure;
/*
 -(void) POSTRefreshKeysOnSuccess:(void(^)(void)) onSuccess
                         onFailure:(void(^)(NSString* error)) onFailure;
 */
@end
