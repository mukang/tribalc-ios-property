//
//  TCCommunityListInCity.m
//  individual
//
//  Created by 穆康 on 2016/12/14.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCommunityListInCity.h"
#import "TCCommunity.h"

@implementation TCCommunityListInCity

+ (NSDictionary *)objectClassInArray {
    return @{@"communityList": [TCCommunity class]};
}

@end
