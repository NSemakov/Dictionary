//
//  NVAnimationNavController.m
//  UpYourDictionary
//
//  Created by Admin on 20/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVAnimationNavController.h"
@interface NVAnimationNavController()
@property (strong,nonatomic) id <UIViewControllerContextTransitioning> storedContext;

@end

@implementation NVAnimationNavController

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (NSTimeInterval) durationOfTransition {
    return 1.0;
}
#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    if (!self.storedContext) {
        self.storedContext = transitionContext;
    }
    
    return [NVAnimationNavController durationOfTransition];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:toVC.view];
    
    if (self.operation == UINavigationControllerOperationPush) {
        toVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(fromVC.view.bounds), 0);
        [UIView animateWithDuration:[NVAnimationNavController durationOfTransition] delay:0.f usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
            toVC.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        [[transitionContext containerView] bringSubviewToFront:fromVC.view];
        [UIView animateWithDuration:[NVAnimationNavController durationOfTransition] delay:0.f usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
            fromVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(toVC.view.bounds), 0);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    
}

- (void) hanglePan:(UIPanGestureRecognizer*) recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGFloat progress = fabs(translation.x/(CGRectGetWidth(recognizer.view.bounds)));
    progress = MIN(MAX(progress, 0.01), 0.99);
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged:
            [self updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled :{
            CALayer* transitionLayer = [self.storedContext containerView].layer;
            //transitionLayer.beginTime = CACurrentMediaTime();
            if (progress < 0.5) {
                //self.completionSpeed = -1.0;
                [self cancelInteractiveTransition];
            } else {
                //self.completionSpeed = 1.0;
                [self finishInteractiveTransition];
            }
            self.interactive = NO;
        }
        default:
            break;
    }
}


@end
