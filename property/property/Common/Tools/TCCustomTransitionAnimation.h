//
//  TCCustomTransitionAnimation.h
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCustomTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval transitionDuration; // Default is 0.5
@property (nonatomic, assign) UIViewContentMode beganMode; // Default is UIViewContentModeScaleAspectFill
@property (nonatomic, assign) UIViewContentMode endMode;  // Default is UIViewContentModeScaleAspectFill

- (void)setupAnimationWithTopImage:(UIImage *)topImage beginRect:(CGRect)beginRect; // end rect 默认为攻略 header
- (void)setupAnimationWithTopImage:(UIImage *)topImage beginRect:(CGRect)beginRect endRect:(CGRect)endRect;

@end
