//
//  TCUserSipInfo.h
//  individual
//
//  Created by 穆康 on 2016/12/26.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 sip信息
 */
@interface TCUserSipInfo : NSObject

/** sip用户名 */
@property (copy, nonatomic) NSString *user;
/** sip用户密码 */
@property (copy, nonatomic) NSString *password;
/** sip域名 */
@property (copy, nonatomic) NSString *domain;
/** 授权设备信息 */
@property (copy, nonatomic) NSDictionary *equips;

@end
