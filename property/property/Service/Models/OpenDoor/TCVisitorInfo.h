//
//  TCVisitorInfo.h
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 访客信息
 */
@interface TCVisitorInfo : NSObject

/** 门锁设备ID */
@property (copy, nonatomic) NSString *equipId;
/** 访客电话，自己开门为空 */
@property (copy, nonatomic) NSString *phone;
/** 访客姓名，自己开门为空 */
@property (copy, nonatomic) NSString *name;
/** 起效时间，自己开门为空 */
@property (nonatomic) NSInteger beginTime;
/** 截止时间，自己开门为空 */
@property (nonatomic) NSInteger endTime;

@end
