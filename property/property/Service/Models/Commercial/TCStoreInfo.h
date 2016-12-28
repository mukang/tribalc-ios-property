//
//  TCStoreInfo.h
//  individual
//
//  Created by 穆康 on 2016/11/29.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCStoreInfo : NSObject

@property (copy, nonatomic) NSString *ID;
/** 店铺名称 */
@property (copy, nonatomic) NSString *name;
/** 店铺LogoURL */
@property (copy, nonatomic) NSString *logo;
/** 店铺品牌 */
@property (copy, nonatomic) NSString *brand;
/** 缩略图 */
@property (copy, nonatomic) NSString *thumbnail;
/** 位置信息 */
@property (copy, nonatomic) NSArray *coordinate;
/** 辅助设施 */
@property (copy, nonatomic) NSArray *faclities;
/** 折扣信息 */
@property (nonatomic) CGFloat discount;
/** 标示性位置 */
@property (copy, nonatomic) NSString *markPlace;
/** 商家标签 */
@property (copy, nonatomic) NSArray *tags;

@end
