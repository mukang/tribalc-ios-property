//
//  TCNavigationDelegate.h
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TTTransitionTypePush,
    TTTransitionTypePop,
    TTTransitionTypeBoth
} TTTransitionType;
@protocol TCTransitionAnimationSupportDelegate <NSObject>

- (BOOL)isTransitionAnimationSupport;

- (id<UIViewControllerAnimatedTransitioning>)pushTransitionAnimationSupport;
- (id<UIViewControllerAnimatedTransitioning>)popTransitionAnimationSupport;

@optional
- (id<UIViewControllerAnimatedTransitioning>)pushTransitionObjectForTargetViewController:(id)toViewController;

@end
@interface TCNavigationDelegate : NSObject<UINavigationControllerDelegate>

+ (TCNavigationDelegate *) shareDelegate;

@end
