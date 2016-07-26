//
//  NVNavigationController.h
//  UpYourDictionary
//
//  Created by Admin on 25/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVNavigationController : UINavigationController <UINavigationControllerDelegate>
@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;
@property (strong, nonatomic) NSMutableArray* vcStack;
@end
