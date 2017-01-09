//
//  TCFadeOutTransitionAnimation.m
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCFadeOutTransitionAnimation.h"

@implementation TCFadeOutTransitionAnimation
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [[transitionContext containerView] addSubview:fromVC.view];
    [[transitionContext containerView] addSubview:toVC.view];
    toVC.view.alpha = 0;
    
    UITabBar * tabbar = fromVC.tabBarController.tabBar;
    tabbar.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVC.view.alpha = 1;
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        fromVC.view.alpha = 1;
        tabbar.alpha = 1;
        [transitionContext completeTransition:YES];
    }];
}

@end
