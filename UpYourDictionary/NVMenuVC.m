//
//  NVMenuVC.m
//  UpYourDictionary
//
//  Created by Admin on 21/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVMenuVC.h"
#import "NVMainStrategy.h"
#import "NVAnimationNavController.h"
//#import "NVNavigationController.h"
@interface NVMenuVC ()
@property (strong, nonatomic) NVAnimationNavController *animationC;
@end

@implementation NVMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NVMainStrategy* manager = [NVMainStrategy sharedManager];
    manager.delegate = self;
    /*set and then adjust font size if user change it*/
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
    [NVCommonManager setupBackgroundImage:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    /*end of adjusting font*/
    self.navigationController.delegate = self;
    //UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    //[self.view addGestureRecognizer:recognizer];
    NVAnimationNavController* animationC = [[NVAnimationNavController alloc] init];
    animationC.animator = animationC;
    self.animationC = animationC;
}

-(void)viewDidAppear:(BOOL)animated{
  

}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showWord:(NSString*) word translation:(NSString*) translation{
    //self.textFieldTest.text = [NSString stringWithFormat:@"%@ - %@",word,translation];
}
#pragma mark - helpers 

-(void) didChangePreferredContentSize:(NSNotification*) notification {
    [NVCommonManager setupFontsForView:self.view andSubViews:YES];
}

- (void) didPan:(UIPanGestureRecognizer*) recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.animationC.interactive = YES;
            [self performSegueWithIdentifier:@"segueChooseDict" sender:nil];
            break;
        }
            
        default:
            [self.animationC hanglePan:recognizer];
            break;
    }
}
#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC{
    
    //NVAnimationNavController* animationC = [[NVAnimationNavController alloc] init];
    self.animationC.operation = operation;
   // self.animationC = animationC;
    
    
    return self.animationC;
}
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
    if (!self.animationC.interactive){
        return nil;
    } else {
        return self.animationC;
    }
    
}
/*
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NVNavigationController* nav = (NVNavigationController*)navigationController;
    if ([nav.vcStack count]) {//если в очереди есть контроллер, показываем его
        NSLog(@"nav ");
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            [self.navigationController showViewController:(UIViewController*)[nav.vcStack lastObject] sender:nil];;
        } else {
            [self.navigationController pushViewController:(UIViewController*)[nav.vcStack lastObject] animated:YES];
        }
        [nav.vcStack removeObject:[nav.vcStack lastObject]];
    }
    nav.shouldIgnorePushingViewControllers = NO;
}
 */
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
