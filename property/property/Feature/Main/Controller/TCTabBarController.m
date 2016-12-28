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
//#import "TCVicinityViewController.h"
#import "TCHomeViewController.h"
//#import "TCCommunitiesViewController.h"
//#import "TCToolsViewController.h"

#import "TCTabBar.h"

@interface TCTabBarController ()

@end

@implementation TCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildController:[[TCHomeViewController alloc] init] title:@"首页" image:@"tabBar_home_normal" selectedImage:@"tabBar_home_selected"];
    [self addChildController:[[UIViewController alloc] init] title:@"社区" image:@"tabBar_discover_normal" selectedImage:@"tabBar_discover_selected"];
    [self addChildController:[[TCProfileViewController alloc] init] title:@"我的" image:@"tabBar_profile_normal" selectedImage:@"tabBar_profile_selected"];
    self.tabBar.translucent = NO;
//    [self setValue:[[TCTabBar alloc] init] forKey:@"tabBar"];
    
//    [self registerNotifications];
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
    if ([title isEqualToString:@"附近"]) {
        nav.tabBarItem.imageInsets = UIEdgeInsetsMake(-10, 0, 10, 0);
    }
    nav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    [self addChildViewController:nav];
}

#pragma mark - notification

//- (void)registerNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickVicinityButton:) name:TCVicinityButtonDidClickNotification object:nil];
//}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - actions

//- (void)handleClickVicinityButton:(NSNotification *)noti {
//    TCVicinityViewController *vicinityVC = [[TCVicinityViewController alloc] init];
//    TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:vicinityVC];
//    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:nav animated:YES completion:nil];
//}



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
