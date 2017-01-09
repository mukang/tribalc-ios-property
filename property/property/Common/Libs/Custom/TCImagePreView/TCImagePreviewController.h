//
//  TCImagePreviewController.h
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCImagePreviewObject.h"
#import "TCNavigationDelegate.h"

//@protocol TCTransitionAnimationSupportDelegate <NSObject>
//
//- (BOOL)isTransitionAnimationSupport;
//
//- (id<UIViewControllerAnimatedTransitioning>)pushTransitionAnimationSupport;
//- (id<UIViewControllerAnimatedTransitioning>)popTransitionAnimationSupport;
//
//@optional
//- (id<UIViewControllerAnimatedTransitioning>)pushTransitionObjectForTargetViewController:(id)toViewController;
//
//@end


@protocol TCImagePreviewControllerDelegate <NSObject>

- (CGRect)transitionAnimationImageEndRectWithIndex:(NSInteger)index;

@end

@interface TCImagePreviewController : UIViewController<TCTransitionAnimationSupportDelegate>

@property (nonatomic, strong) NSArray<TCImagePreviewObject*>* models;
@property (nonatomic, assign) NSInteger currentIndex; // 设置 currentIndex 初始值 可以直接跳转到指定页面
@property (nonatomic, assign) BOOL appearWithAnimation;
@property (nonatomic, weak) id<TCImagePreviewControllerDelegate> delegate;

- (id<UIViewControllerAnimatedTransitioning>)fetchTransitionAnimationWithImageUrl:(NSURL*)imageUrl beganRect:(CGRect)begnRect;

@end
