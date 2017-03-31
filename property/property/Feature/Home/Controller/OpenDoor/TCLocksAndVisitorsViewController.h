//
//  TCLocksAndVisitorsViewController.h
//  individual
//
//  Created by 王帅锋 on 17/3/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>

typedef NS_ENUM(NSInteger, TCLocksOrVisitors) {
    TCLocks,
    TCVisitors
};

@interface TCLocksAndVisitorsViewController : TCBaseViewController

- (instancetype)initWithType:(TCLocksOrVisitors)locksOrVisitors;

@end
