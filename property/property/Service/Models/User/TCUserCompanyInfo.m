//
//  TCUserCompanyInfo.m
//  individual
//
//  Created by 穆康 on 2016/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserCompanyInfo.h"
#import "TCCompanyInfo.h"
#import "TCCommunity.h"

@implementation TCUserCompanyInfo

+ (NSDictionary *)objectClassInDictionary {
    return @{
             @"company": [TCCompanyInfo class],
             @"community": [TCCommunity class]
             };
}

@end
