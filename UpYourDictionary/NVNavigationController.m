//
//  NVNavigationController.m
//  UpYourDictionary
//
//  Created by Admin on 25/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVNavigationController.h"



@interface NVNavigationController ()



@end

@implementation NVNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.vcStack = [NSMutableArray new];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!self.shouldIgnorePushingViewControllers)
    {
        [super pushViewController:viewController animated:animated];
    } else {
        [self.vcStack addObject:viewController];
    }
    self.shouldIgnorePushingViewControllers = YES;
}
-(void)showViewController:(UIViewController *)vc sender:(id)sender{
    if (!self.shouldIgnorePushingViewControllers)
    {
        [super showViewController:vc sender:sender];
    } else {
        [self.vcStack addObject:vc];
    }
    self.shouldIgnorePushingViewControllers = YES;
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    self.shouldIgnorePushingViewControllers = NO;
    
    if ([self.vcStack count]) {
        [self showViewController:[self.vcStack lastObject]  sender:nil];
    }
}

@end
