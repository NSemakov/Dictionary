//
//  NVServerManager.m
//  UpYourDictionary
//
//  Created by Admin on 28.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NVServerManager.h"

static const NSString *APIKey=@"trnsl.1.1.20160515T105554Z.bebe36c462114c01.c2bb5a4b68973e1128a3aed89cbd817e9fb603ab";

@implementation NVServerManager

+(NVServerManager*) sharedManager{
    static NVServerManager* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVServerManager alloc]init];
    });
    return manager;
}

-(void) POSTListOfDirectionsOnSuccess:(void(^)(NSDictionary* languages)) onSuccess
onFailure:(void(^)(NSString* error)) onFailure{

    NSURL* baseURL=[NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              APIKey, @"key",
                              @"en", @"ui",
                              nil];
    [self.manager POST:@"getLangs" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        //NSLog(@"coming %@",responseObject);
       
        /*for (NSDictionary* obj in [[responseObject objectForKey:@"response"] objectForKey:@"items"]){
            
        }*/
        if (onSuccess) {
            onSuccess(responseObject);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        //NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",ErrorResponse);
        //NSLog(@"%@",error.localizedDescription);
       // NSLog(@"error %@ code %ld",error,operation.error.code);
        if (onFailure) {
            NSString* returnString=[NSString stringWithFormat:@"error %@ code %d",error,operation.error.code];
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
        NSLog(@"coming %@",responseObject);
        
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
        NSLog(@"error %@ code %d",error,operation.error.code);
        if (onFailure) {
            NSString* returnString=[NSString stringWithFormat:@"error %@ code %d",error,operation.error.code];
            onFailure(returnString);
        }
    }];
    
}
/*-(void) POSTTranslatePhrase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess
                       onFailure:(void(^)(NSString* error)) onFailure{
    
    NSURL* baseURL=[NSURL URLWithString:@"https://translate.yandex.net/api/v1.5/tr.json"];
    self.manager =[[AFHTTPSessionManager alloc]initWithBaseURL:baseURL];
    NSString* direction = [NSString stringWithFormat:@"%@-%@",fromLang,toLang];
    NSDictionary* dictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              APIKey, @"key",
                              phrase, @"text",
                               direction, @"lang",
                              nil];
    [self.manager POST:@"translate" parameters:dictionary progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        //NSLog(@"coming %@",responseObject);
        

        NSString* translation = [[responseObject objectForKey:@"text"] firstObject];
        if (onSuccess) {
            onSuccess(translation);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ErrorResponse);
        NSLog(@"%@",error.localizedDescription);
         NSLog(@"error %@ code %d",error,operation.error.code);
        if (onFailure) {
            NSString* returnString=[NSString stringWithFormat:@"error %@ code %d",error,operation.error.code];
            onFailure(returnString);
        }
    }];
}
*/
@end
