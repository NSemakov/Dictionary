//
//  UpYourDictionaryTests.m
//  UpYourDictionaryTests
//
//  Created by Admin on 15/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NVServerManager.h"
@interface UpYourDictionaryTests : XCTestCase

@end

@implementation UpYourDictionaryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
- (void)testThatChairIsRetrievedFromFirebase {
    [[NVServerManager sharedManager] POSTSearchInCachedWordsAtFirebase:@"Стул" fromLang:@"ru" toLang:@"en" OnSuccess:^(NSString *translation) {
        NSLog(@"all ok");
    } onFailure:^(NSString *error) {
        NSLog(@"all wrong");
    }];
}
@end
