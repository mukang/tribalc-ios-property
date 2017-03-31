//
//  TCAddVisitorViewController.h
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>
@class TCLockKey;

typedef void(^TCAddVisitorCompletion)();

@interface TCAddVisitorViewController : TCBaseViewController

@property (weak, nonatomic) UIViewController *fromController;
@property (copy, nonatomic) TCAddVisitorCompletion addVisitorCompletion;

@end
