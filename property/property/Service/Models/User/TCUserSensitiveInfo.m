//
//  TCUserSensitiveInfo.m
//  individual
//
//  Created by 穆康 on 2016/11/10.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserSensitiveInfo.h"
#import <TCCommonLibs/NSObject+TCModel.h>

@implementation TCUserSensitiveInfo

+ (NSDictionary *)objectClassInDictionary {
    return @{
             @"sip": [TCUserSipInfo class]
             };
}

@end
