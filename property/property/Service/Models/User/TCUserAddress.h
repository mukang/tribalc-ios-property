//
//  TCUserAddress.h
//  individual
//
//  Created by 穆康 on 2016/11/11.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 用户所在地
 */
@interface TCUserAddress : NSObject

/** 省份 */
@property (copy, nonatomic) NSString *province;
/** 城市 */
@property (copy, nonatomic) NSString *city;
/** 城区 */
@property (copy, nonatomic) NSString *district;

@end
