//
//  TCUserCompanyInfo.h
//  individual
//
//  Created by 穆康 on 2016/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TCCompanyInfo;

@interface TCUserCompanyInfo : NSObject

/** 公司信息 */
@property (strong, nonatomic) TCCompanyInfo *company;
/** 公司部门 */
@property (copy, nonatomic) NSString *department;
/** 职位 */
@property (copy, nonatomic) NSString *position;
/** 工号 */
@property (copy, nonatomic) NSString *personNum;
/** 请求状态（PROCESSING, SUCCEED, FAILURE, NOT_BIND） */
@property (copy, nonatomic) NSString *comfirmed;

@end
