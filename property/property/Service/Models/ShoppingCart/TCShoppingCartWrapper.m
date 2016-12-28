//
//  TCShoppingCartWrapper.m
//  individual
//
//  Created by WYH on 16/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShoppingCartWrapper.h"
#import "TCListShoppingCart.h"

@implementation TCShoppingCartWrapper

+ (NSDictionary *)objectClassInArray {
    return @{@"content": [TCListShoppingCart class]};
}


@end
