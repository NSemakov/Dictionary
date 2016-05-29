//
//  NVServerManager.h
//  45. APIWithoutAccessToken
//
//  Created by Admin on 28.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@class NVAccessToken;
@interface NVServerManager : NSObject
@property (strong,nonatomic) NVAccessToken* accessToken;
@property (strong,nonatomic) AFHTTPSessionManager* manager;
+(NVServerManager*) sharedManager;
-(void) POSTListOfDirectionsOnSuccess:(void(^)(NSDictionary* languages)) onSuccess
                        onFailure:(void(^)(NSString* error)) onFailure;
-(void) POSTTranslatePhrase:(NSString*) phrase fromLang:(NSString*) fromLang toLang:(NSString*) toLang OnSuccess:(void(^)(NSString* translation)) onSuccess onFailure:(void(^)(NSString* error)) onFailure;
/*-(void) getFriendsFromServerCount:(NSInteger) count
                       withOffset:(NSInteger) offset
                        onSuccess:(void(^)(NSArray* friends)) onSuccess
                        onFailure:(void(^)(NSString* error)) onFailure;
-(void) getDetailOfFriendFromServer:(NSString*) userIds
                               onSuccess:(void(^)(NVUser* person)) onSuccess
                               onFailure:(void(^)(NSString* error)) onFailure;
-(void) getFollowersFromServer:(NSInteger) userIds Count:(NSInteger) count
                    withOffset:(NSInteger) offset
                     onSuccess:(void(^)(NSArray* followers)) onSuccess
                     onFailure:(void(^)(NSString* error)) onFailure;
-(void) getSubscriptionsFromServer:(NSString*) userIds Count:(NSInteger) count
                        withOffset:(NSInteger) offset
                         onSuccess:(void(^)(NSArray* subscriptions)) onSuccess
                         onFailure:(void(^)(NSString* error)) onFailure;
-(void) getWallPostsOfFriendFromServer:(NSString*) owner_id
                                 Count:(NSInteger) count
                            withOffset:(NSInteger) offset
                             onSuccess:(void(^)(NSArray* wallPosts)) onSuccess
                             onFailure:(void(^)(NSString* error)) onFailure;
-(void) getUserFromServer:(NSString*) userId
                onSuccess:(void(^)(NVUser * user)) onSuccess
                onFailure:(void(^)(NSString* error)) onFailure;
- (void) authorizeUser:(void(^)(NVUser* user))completion;
- (void)postWallCreateCommentText:(NSString*)text
                            image:(NSArray *)image
                      onGroupWall:(NSString*)groupID
                        onSuccess:(void(^)(id result))success
                        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;
 */
@end
