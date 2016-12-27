//
//  TCSipAPI.h
//  individual
//
//  Created by 王帅锋 on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinphoneManager.h"
#import "TCLinphoneUtils.h"

@interface TCSipAPI : NSObject

- (BOOL)isLogin;

- (void)login;

+ (instancetype)api;

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state;

@end
