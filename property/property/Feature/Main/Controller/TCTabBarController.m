//
//  TCTabBarController.m
//  individual
//
//  Created by 穆康 on 2016/10/26.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCTabBarController.h"
#import "TCNavigationController.h"
#import "TCProfileViewController.h"
#import "TCHomeViewController.h"
#import "TCOrderViewController.h"
#import "TCLoginViewController.h"
#import "TCBuluoApi.h"
#import "TCTabBar.h"

#import <AMapFoundationKit/AMapFoundationKit.h>

static NSString *const AMapApiKey = @"ebbe753a2efddfdfbaedef9a3bd58d15";

@interface TCTabBarController () <UITabBarControllerDelegate>

@end

@implementation TCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.delegate = self;
    
    [self addChildController:[[TCHomeViewController alloc] init] title:@"社区" image:@"tabBar_community_normal" selectedImage:@"tabBar_community_selected"];
    [self addChildController:[[TCOrderViewController alloc] init] title:@"订单" image:@"tabBar_order_normal" selectedImage:@"tabBar_order_selected"];
    [self addChildController:[[TCProfileViewController alloc] init] title:@"我的" image:@"tabBar_profile_normal" selectedImage:@"tabBar_profile_selected"];
    self.tabBar.translucent = NO;
    
    [self setupAMapServices];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)addChildController:(UIViewController *)childController title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selecteImage {
    
    childController.navigationItem.title = title;
    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:childController];
    
    [nav.tabBarItem setTitleTextAttributes:@{
                                             NSForegroundColorAttributeName : TCRGBColor(112, 112, 112)
                                             }
                                  forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{
                                             NSForegroundColorAttributeName : TCRGBColor(67, 67, 67)
                                             }
                                  forState:UIControlStateSelected];
    nav.tabBarItem.title = title;
    nav.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:selecteImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    [self addChildViewController:nav];
}

#pragma mark - notification


- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    TCNavigationController *vc = (TCNavigationController *)viewController;
    if ([vc.childViewControllers[0] isKindOfClass:[TCOrderViewController class]] && [[TCBuluoApi api] needLogin]) {
        [self showLoginViewController];
        return NO;
    }
    return YES;
}

#pragma mark - Show Login View Controller

- (void)showLoginViewController {
    TCLoginViewController *vc = [[TCLoginViewController alloc] initWithNibName:@"TCLoginViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - AMapServices

- (void)setupAMapServices {
    [AMapServices sharedServices].apiKey = AMapApiKey;
    [AMapServices sharedServices].enableHTTPS = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
