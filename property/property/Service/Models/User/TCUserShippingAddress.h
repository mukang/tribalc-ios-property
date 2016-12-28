//
//  TCUserShippingAddress.h
//  individual
//
//  Created by 穆康 on 2016/11/15.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUserShippingAddress : NSObject

/** 地址ID */
@property (copy, nonatomic) NSString *ID;
/** 收货省份 */
@property (copy, nonatomic) NSString *province;
/** 收货城市 */
@property (copy, nonatomic) NSString *city;
/** 收货城区 */
@property (copy, nonatomic) NSString *district;
/** 详细地址 */
@property (copy, nonatomic) NSString *address;
/** 收货人姓名 */
@property (copy, nonatomic) NSString *name;
/** 收货人手机号 */
@property (copy, nonatomic) NSString *phone;
/** 是否是默认收货地址 */
@property (nonatomic, getter=isDefaultAddress) BOOL defaultAddress;

@end
