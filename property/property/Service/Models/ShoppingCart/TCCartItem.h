//
//  TCCartItem.h
//  individual
//
//  Created by WYH on 16/12/13.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGoods.h"

@interface TCCartItem : UIView

/** 购物车商品id */
@property (copy, nonatomic) NSString *ID;
/** 商品数量 */
@property (nonatomic) NSInteger amount;
/** 购物车商品id */
@property (retain, nonatomic) TCGoods *goods;
/** 规格id */
@property (copy, nonatomic) NSString *standardId;
/** 库存剩余量 */
@property (assign, nonatomic) NSInteger repertory;

@property (nonatomic) BOOL select;

@end
