//
//  TCCustomTransitionAnimation.m
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCustomTransitionAnimation.h"

@interface TCCustomTransitionAnimation()

@property (nonatomic, strong) UIImage * topImage;
@property (nonatomic, assign) CGRect beginRect;
@property (nonatomic, assign) CGRect endRect;

@end

@implementation TCCustomTransitionAnimation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionDuration = 0.5;
        _beganMode = UIViewContentModeScaleAspectFill;
        _endMode = UIViewContentModeScaleAspectFill;
    }
    
    return self;
}

- (void)setupAnimationWithTopImage:(UIImage *)topImage beginRect:(CGRect)beginRect endRect:(CGRect)endRect
{
    self.topImage = topImage;
    self.beginRect = beginRect;
    self.endRect = endRect;
}

- (void)setupAnimationWithTopImage:(UIImage *)topImage beginRect:(CGRect)beginRect
{
    [self setupAnimationWithTopImage:topImage beginRect:beginRect endRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (206 * [UIScreen mainScreen].bounds.size.width / 375))];
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    CGRect rect = self.beginRect;
    UIImageView * imageview;
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    imageview.backgroundColor = [UIColor whiteColor];
    [toVC.view addSubview:imageview];
    imageview.image = self.topImage;
    imageview.contentMode = _beganMode;
    imageview.clipsToBounds = YES;
    imageview.tag = 1001;
    if(!self.topImage){
        imageview.alpha = 0;
    }
    
    [[transitionContext containerView] addSubview:fromVC.view];
    [[transitionContext containerView] addSubview:toVC.view];
    toVC.view.alpha = 0;
    
    //tabbar渐隐动画
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect tabbarRect = fromVC.tabBarController.tabBar.frame;
    CGRect realTabRect = CGRectMake(0, tabbarRect.origin.y, fromVC.view.frame.size.width, tabbarRect.size.height);
    UIView * tabView = [window resizableSnapshotViewFromRect:realTabRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    tabView.frame = realTabRect;
    [window addSubview:tabView];
    
    UITabBar * tabbar = fromVC.tabBarController.tabBar;
    tabbar.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toVC.view.alpha = 1;
        fromVC.view.alpha = 0;
        imageview.frame = self.endRect;
        tabView.alpha = 0;
        imageview.contentMode = _endMode;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        fromVC.view.alpha = 1;
        tabbar.alpha = 1;
        [tabView removeFromSuperview];
        [imageview removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end

