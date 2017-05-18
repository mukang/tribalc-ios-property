//
//  TCMultiLockKey.h
//  individual
//
//  Created by 穆康 on 2017/5/17.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCMultiLockKey : NSObject

/** 设备ID */
@property (copy, nonatomic) NSString *ID;
/** 所有者ID */
@property (copy, nonatomic) NSString *ownerId;
/** 锁名称列表 */
@property (copy, nonatomic) NSArray *equipNames;
/** 申请时间 */
@property (assign, nonatomic) long long createTime;
/** 起效时间 */
@property (assign, nonatomic) long long beginTime;
/** 截止时间 */
@property (assign, nonatomic) long long endTime;
/** 二维码数据 */
@property (copy, nonatomic) NSString *key;
/** 访客手机，如果为空表示为所有者本人 */
@property (copy, nonatomic) NSString *phone;
/** 访客人名字，如果为空表示为所有者本人 */
@property (copy, nonatomic) NSString *name;

@end
