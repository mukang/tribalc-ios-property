//
//  TCListShoppingCart.h
//  individual
//
//  Created by WYH on 16/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCModelImport.h"

@interface TCListShoppingCart : NSObject

/** 购物车条目id */
@property (copy, nonatomic) NSString *ID;
/** 商品列表 TCCartItem对象 */
@property (copy, nonatomic) NSArray *goodsList;
/** 店铺信息 */
@property (nonatomic) TCMarkStore *store;

@end
