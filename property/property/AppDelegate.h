//
//  AppDelegate.h
//  property
//
//  Created by 王帅锋 on 16/12/27.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *launchWindow;

/** 显示启动视窗 */
- (void)showLaunchWindow;

@end

