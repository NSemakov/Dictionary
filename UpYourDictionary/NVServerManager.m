//
//  NVServerManager.m
//  UpYourDictionary
//
//  Created by Admin on 28.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NVServerManager.h"
#import <AFNetworking/AFNetworking.h>
@import Firebase;

static const NSString *APIKey = @"trnsl.1.1.20160515T105554Z.bebe36c462114c01.c2bb5a4b68973e1128a3aed89cbd817e9fb603ab";
static const NSString *DictAPIKey = @"dict.1.1.20160529T231224Z.83fb051c8f95bf0d.518bafee59b93d53f8728010cbdc3ea7dddef245";

@implementation NVServerManager

+(NVServerManager*) sharedManager{
    static NVServerManager* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVServerManager alloc]init];
    });
    return manager;
}
#pragma mark - accessors
-(void)setAPIDictKey:(NSString *)APIDictKey{
    [[NSUserDefaults standardUserDefaults] setValue:APIDictKey forKey:NVDictionaryAPIKey];
}
-(void)setAPITranslatorKey:(NSString *)APITranslatorKey{
    [[NSUserDefaults standardUserDefaults] setValue:APITranslatorKey forKey:NVTranslatorAPIKey];
}
-(NSString *)APIDictKey{
    NSString* key = [[NSUserDefaults standardUserDefaults] objectForKey:NVDictionaryAPIKey];
    //NSLog(@"key api dict:%@",key);
    return [key length] > 0 ? key:DictAPIKey;
}
-(NSString *)APITranslatorKey{
    NSString* key = [[NSUserDefaults standardUserDefaults] objectForKey:NVTranslatorAPIKey];
    //NSLog(@"APITranslatorKey:%@",key);
    return [key length] > 0 ? key:APIKey;
}
-(void) POSTListOfDirectionsOnLang:(NSString*) lang OnSuccess:(void(^)(NSDictionary* languages)) onSuccess
onFailure:(void(^)(NSString* error)) onFailure{

    NSURL* baseURL=[NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              self.APITranslatorKey, @"key",
                              lang, @"ui",
                              nil];
    [self.manager POST:@"getLangs" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        //NSLog(@"coming %@",responseObject);
       
        /*for (NSDictionary* obj in [[responseObject objectForKey:@"response"] objectForKey:@"items"]){
            
        }*/
        if (onSuccess) {
            onSuccess(responseObject);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",ErrorResponse);
        //NSLog(@"%@",error.localizedDescription);
       // NSLog(@"error %@ code %ld",error,operation.error.code);
        if (onFailure) {
            //NSString* returnString=[NSString stringWithFormat:@"error %@ code %ld",error,operation.error.code];
            onFailure(ErrorResponse);
        }
    }];
}

-(void) POSTLookUpDictionary:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                  onFailure:(void(^)(NSString* error)) onFailure{
    //NSLog(@"from lang %@, to lang %@, phrase %@",fromLang, toLang, phrase);
    //https:// dictionary.yandex.net/api/v1/dicservice.json/ lookup?key= API-ключ&lang=en-ru&text=time
    NSURL* baseURL=[NSURL URLWithString:@"https://dictionary.yandex.net/api/v1/dicservice.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    NSString* direction = [NSString stringWithFormat:@"%@-%@",fromLang,toLang];
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              self.APIDictKey, @"key",
                              phrase, @"text",
                              direction, @"lang",
                              @"ru", @"ui",
                              nil];
    
    [self.manager POST:@"lookup" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        //NSLog(@"coming lookup %@",responseObject);
        
        /*for (NSDictionary* obj in [[responseObject objectForKey:@"response"] objectForKey:@"items"]){
         
         }*/
        NSString* translation;
        NSArray* defArray = [responseObject objectForKey:@"def"];
        if ([defArray count]>0) {
            NSArray *trArray = [[defArray firstObject] objectForKey:@"tr"];
            if ([trArray count] > 0) {
                translation = [[trArray firstObject] objectForKey:@"text"];
            } else {
                translation = nil;
            }
            
        } else {
            translation = nil;
        }
        
        if (onSuccess) {
            onSuccess(translation);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ErrorResponse);
        NSLog(@"%@",error.localizedDescription);
        NSLog(@"error %@ code %ld",error,operation.error.code);
        if (onFailure) {
            onFailure(ErrorResponse);
        }
    }];
    
}
-(void) POSTTranslatePhrase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                  onFailure:(void(^)(NSString* error)) onFailure{
    //NSLog(@"from lang %@, to lang %@, phrase %@",fromLang, toLang, phrase);
    NSURL* baseURL=[NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    NSString* direction = [NSString stringWithFormat:@"%@-%@",fromLang,toLang];
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              self.APITranslatorKey, @"key",
                              phrase, @"text",
                              direction, @"lang",
                              nil];
    //NSParameterAssert(self.manager); // prevent infinite loop
    
    [self.manager POST:@"translate" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        //NSLog(@"coming %@",responseObject);
        
        /*for (NSDictionary* obj in [[responseObject objectForKey:@"response"] objectForKey:@"items"]){
         
         }*/
        NSString* translation = [[responseObject objectForKey:@"text"] firstObject];
        if (onSuccess) {
            onSuccess(translation);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ErrorResponse);
        NSLog(@"%@",error.localizedDescription);
        NSLog(@"error %@ code %ld",error,operation.error.code);
        if (onFailure) {
            //NSString* returnString=[NSString stringWithFormat:@"error %@ code %ld",error,operation.error.code];
            onFailure(ErrorResponse);
        }
    }];
    
}
-(void) POSTSearchInCachedWordsAtFirebase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                                onFailure:(void(^)(NSString* error)) onFailure{
    //FIRDatabaseQuery *recentPostsQuery = [[self.remoteDB child:@"posts"] queryStartingAtValue:<#(nullable id)#>];
   // FIRDatabaseQuery *recentPostsQuery = [[self.remoteDB child:@"posts"] queryLimitedToFirst:1];
    //FIRDatabaseQuery *recentPostsQuery = [[self.remoteDB child:@"posts"] queryEqualToValue:1];
    NSString* indexed = [NSString stringWithFormat:@"LangFrom%@LangTo%@OriginalWord%@",fromLang, toLang, phrase];

    FIRDatabaseReference* cachedWordsFromYandexTranslate = [[self.remoteDB child:@"CachedWordsFromYandexTranslate"] child:indexed];
    
    [cachedWordsFromYandexTranslate observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
         NSString* translation = snapshot.value;
         if (![translation isEqual:[NSNull null]] && translation.length > 0) {
             onSuccess(translation);
         } else {
             onFailure(@"Error: no translation is found in post search");
         }
    }];
}
-(void) POSTAddToCachedWordsAtFirebase:(NSString*) phrase translation:(NSString*) translation fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                             onFailure:(void(^)(NSString* error)) onFailure{
    NSString* indexed = [NSString stringWithFormat:@"LangFrom%@LangTo%@OriginalWord%@",fromLang, toLang, phrase];
    [[[self.remoteDB child:@"CachedWordsFromYandexTranslate"] child:indexed] setValue:translation];
    NSLog(@"added to firebase word: %@",translation);
}
-(BOOL)isNetworkAvailable
{/*
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "ya.ru" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
    */
    
    NSURL *scriptUrl = [NSURL URLWithString:@"https://www.google.com/m"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        return YES;
    else
        return NO;
        //NSLog(@"Device is not connected to the Internet");
    
    /*
    return [AFNetworkReachabilityManager sharedManager].reachable;
*/
}
@end
