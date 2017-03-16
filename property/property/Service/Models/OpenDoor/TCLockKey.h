//
//  TCLockKey.h
//  individual
//
//  Created by 王帅锋 on 17/3/10.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCLockKey : NSObject

/** 设备ID */
@property (copy, nonatomic) NSString *ID;
/** 所有者ID */
@property (copy, nonatomic) NSString *ownerId;
/** 门锁设备ID */
@property (copy, nonatomic) NSString *equipId;
/** 锁名称 */
@property (copy, nonatomic) NSString *equipName;
/** 申请时间 */
@property (assign, nonatomic) NSInteger createTime;
/** 起效时间 */
@property (assign, nonatomic) NSInteger beginTime;
/** 截止时间 */
@property (assign, nonatomic) NSInteger endTime;
/** 二维码数据 */
@property (copy, nonatomic) NSString *key;
/** 访客手机，如果为空表示为所有者本人 */
@property (copy, nonatomic) NSString *phone;
/** 访客人名字，如果为空表示为所有者本人 */
@property (copy, nonatomic) NSString *name;

@end

