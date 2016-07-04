//
//  NVCommonManager.h
//  UpYourDictionary
//
//  Created by Admin on 04/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NVCommonManager : NSObject
+ (void)setupFontsForBars;
+ (void)setupFontsForView:(UIView *)view andSubViews:(BOOL)isSubViews;
+ (void)setupBackgroundImage:(id) viewController;
+ (UIFont*) getReadyFont;
+ (CGFloat) heightForOneLabel:(NSString*)text width:(CGFloat) width;
-(void) configureInitialState;
+(NVCommonManager*) sharedManager;
@end
