//
//  AppDelegate.m
//  property
//
//  Created by 王帅锋 on 16/12/27.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "TCTabBarController.h"
#import "TCSipAPI.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()<CLLocationManagerDelegate>

@end

@implementation AppDelegate{
    CLLocationManager *_locationManager;
    BOOL _isRequest;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    TCTabBarController *tabBarController = [[TCTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    TCSipAPI *sipApi = [TCSipAPI api];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sipApi login];
    });
    
    return YES;
}

- (void)startLocationAction
{
    _locationManager = [[CLLocationManager alloc] init];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    if ([CLLocationManager locationServicesEnabled] &&
        (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
         && !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))) {
            //定位功能可用，开始定位
            _locationManager.delegate=self;
            //设置定位精度
            _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            
            [_locationManager stopUpdatingLocation];
            [_locationManager startUpdatingLocation];
            
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isAllowLocal"];
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"isAllowLocal"];
        }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"isAllowLocal"];
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"isAllowLocal"];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if (!_isRequest) {
        CLLocation *location=[locations lastObject];//取出第一个位置
        CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
        
        _isRequest = YES;
        [_locationManager stopUpdatingLocation];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f,%f",coordinate.latitude, coordinate.longitude] forKey:@"locationLatAndLog"];
        
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    if (![[TCSipAPI api] isLogin]) {
        [[TCSipAPI api] login];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    LinphoneManager *instance = LinphoneManager.instance;
    [instance becomeActive];
    
    LinphoneCall *call = linphone_core_get_current_call(LC);
    
    if (call) {
        if (call == instance->currentCallContextBeforeGoingBackground.call) {
            const LinphoneCallParams *params = linphone_call_get_current_params(call);
            if (linphone_call_params_video_enabled(params)) {
                linphone_call_enable_camera(call, instance->currentCallContextBeforeGoingBackground.cameraIsEnabled);
            }
            instance->currentCallContextBeforeGoingBackground.call = 0;
        } else if (linphone_call_get_state(call) == LinphoneCallIncomingReceived) {
            
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
