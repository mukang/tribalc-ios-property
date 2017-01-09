//
//  TCNavigationDelegate.m
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCNavigationDelegate.h"

@implementation TCNavigationDelegate

+ (TCNavigationDelegate*) shareDelegate
{
    static TCNavigationDelegate* delegate = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [TCNavigationDelegate new];
    });
    
    return delegate;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    
    if([fromVC conformsToProtocol:@protocol(TCTransitionAnimationSupportDelegate)]){
        if(operation == UINavigationControllerOperationPush){
            if ([(id<TCTransitionAnimationSupportDelegate>)fromVC isTransitionAnimationSupport]) {
                id<UIViewControllerAnimatedTransitioning> resultTransition = [(id<TCTransitionAnimationSupportDelegate>)fromVC pushTransitionAnimationSupport];
                id<UIViewControllerAnimatedTransitioning> targetTransition = nil;
                if ([fromVC respondsToSelector:@selector(pushTransitionObjectForTargetViewController:)]) {
                    targetTransition = [(id<TCTransitionAnimationSupportDelegate>)fromVC pushTransitionObjectForTargetViewController:toVC];
                }
                return targetTransition?:resultTransition;
            } else {
                return nil;
            }
        }else if (operation == UINavigationControllerOperationPop){
            id<UIViewControllerAnimatedTransitioning> resultTransition = [(id<TCTransitionAnimationSupportDelegate>)fromVC popTransitionAnimationSupport];
            return  [(id<TCTransitionAnimationSupportDelegate>)fromVC isTransitionAnimationSupport] && resultTransition ? resultTransition : nil;
        }
    }
    return nil;
}

@end
