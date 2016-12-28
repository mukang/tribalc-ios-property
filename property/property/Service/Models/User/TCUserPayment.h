//
//  TCUserPayment.h
//  individual
//
//  Created by 穆康 on 2016/12/20.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCUserPayment : NSObject

@property (copy, nonatomic) NSString *ID;
/** 提交时间 */
@property (nonatomic) NSInteger createTime;
/** 提交人资金账户ID（同提交人ID一致） */
@property (copy, nonatomic) NSString *ownerAccountId;
/** 支付状态 Default CREATED From { CREATED, PAYED, FINISHED, FAILURE } */
@property (copy, nonatomic) NSString *status;
/** 支付方式 Default BALANCE From { BALANCE, ALIPAY, WECHAT, BANKCARD } */
@property (copy, nonatomic) NSString *payChannel;
/** 支付总金额 */
@property (nonatomic) CGFloat totalAmount;
/** 备注信息 */
@property (copy, nonatomic) NSString *note;

@end
