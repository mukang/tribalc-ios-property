//
//  TCLockWrapper.m
//  individual
//
//  Created by 王帅锋 on 17/3/10.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLockWrapper.h"
#import "TCLockKey.h"

@implementation TCLockWrapper

+ (NSDictionary *)objectClassInArray {
    return @{@"keys": [TCLockKey class]};
}

@end
