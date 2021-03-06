//
//  TCPropertyDetailController.h
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>
#import "TCNavigationDelegate.h"
@class TCPropertyManage;


@interface TCPropertyDetailController : TCBaseViewController <TCTransitionAnimationSupportDelegate>

- (instancetype)initWithPropertyManage:(TCPropertyManage *)property;

@end
