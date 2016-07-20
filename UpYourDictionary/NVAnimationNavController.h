//
//  NVAnimationNavController.h
//  UpYourDictionary
//
//  Created by Admin on 20/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWPercentDrivenInteractiveTransition.h"
@interface NVAnimationNavController : AWPercentDrivenInteractiveTransition/*UIPercentDrivenInteractiveTransition*/ <UIViewControllerAnimatedTransitioning>
@property (assign, nonatomic) UINavigationControllerOperation operation;
@property (assign, nonatomic) BOOL interactive;
- (void) hanglePan:(UIPanGestureRecognizer*) recognizer;
@end
