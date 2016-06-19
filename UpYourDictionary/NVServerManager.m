//
//  NVServerManager.m
//  UpYourDictionary
//
//  Created by Admin on 28.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NVServerManager.h"

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

-(void) POSTListOfDirectionsOnLang:(NSString*) lang OnSuccess:(void(^)(NSDictionary* languages)) onSuccess
onFailure:(void(^)(NSString* error)) onFailure{

    NSURL* baseURL=[NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              APIKey, @"key",
                              lang, @"ui",
                              nil];
    [self.manager POST:@"getLangs" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSLog(@"coming %@",responseObject);
       
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
            NSString* returnString=[NSString stringWithFormat:@"error %@ code %ld",error,operation.error.code];
            onFailure(returnString);
        }
    }];
}

-(void) POSTLookUpDictionary:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                  onFailure:(void(^)(NSString* error)) onFailure{
    //https:// dictionary.yandex.net/api/v1/dicservice.json/ lookup?key= API-ключ&lang=en-ru&text=time
    NSURL* baseURL=[NSURL URLWithString:@"https://dictionary.yandex.net/api/v1/dicservice.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    NSString* direction = [NSString stringWithFormat:@"%@-%@",fromLang,toLang];
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              DictAPIKey, @"key",
                              phrase, @"text",
                              direction, @"lang",
                              @"ru", @"ui",
                              nil];
    
    [self.manager POST:@"lookup" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        NSLog(@"coming lookup %@",responseObject);
        
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
            NSString* returnString=[NSString stringWithFormat:@"error %@ code %ld",error,operation.error.code];
            onFailure(returnString);
        }
    }];
    
}
-(void) POSTTranslatePhrase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                  onFailure:(void(^)(NSString* error)) onFailure{
    
    NSURL* baseURL=[NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    NSString* direction = [NSString stringWithFormat:@"%@-%@",fromLang,toLang];
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              APIKey, @"key",
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
            NSString* returnString=[NSString stringWithFormat:@"error %@ code %ld",error,operation.error.code];
            onFailure(returnString);
        }
    }];
    
}
-(bool)isNetworkAvailable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef address;
    address = SCNetworkReachabilityCreateWithName(NULL, "ya.ru" );
    Boolean success = SCNetworkReachabilityGetFlags(address, &flags);
    CFRelease(address);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}
@end
