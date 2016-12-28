//
//  TCCartItem.m
//  individual
//
//  Created by WYH on 16/12/13.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCartItem.h"

@implementation TCCartItem

+ (NSDictionary *)objectClassInDictionary {
    return @{
             @"goods": [TCGoods class]
             };
}

@end
