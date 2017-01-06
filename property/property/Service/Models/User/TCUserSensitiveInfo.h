//
//  TCUserSensitiveInfo.h
//  individual
//
//  Created by 穆康 on 2016/11/10.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCUserSipInfo.h"

@interface TCUserSensitiveInfo : NSObject

/** 用户ID */
@property (copy, nonatomic) NSString *ID;
/** 姓名 */
@property (copy, nonatomic) NSString *name;
/** 手机号码 */
@property (copy, nonatomic) NSString *phone;
/** 身份证号码 */
@property (copy, nonatomic) NSString *idNo;
/** 实名认证状态{ NOT_START, PROCESSING, SUCCESS, FAILURE } */
@property (copy, nonatomic) NSString *authorizedStatus;
/** 默认收货地址ID */
@property (copy, nonatomic) NSString *addressID;
/** 所在公司ID */
@property (copy, nonatomic) NSString *companyID;
/** 公司名称 */
@property (copy, nonatomic) NSString *companyName;
/** sip信息 */
@property (strong, nonatomic) TCUserSipInfo *sip;

@end
