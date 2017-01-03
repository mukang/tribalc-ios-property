//
//  TCPropertyManage.h
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPropertyManage : NSObject
/** 条目ID */
@property (copy, nonatomic) NSString *ID;
/** 社区名称 */
@property (copy, nonatomic) NSString *communityName;
/** 公司名称 */
@property (copy, nonatomic) NSString *companyName;
/** 申请人姓名 */
@property (copy, nonatomic) NSString *applyPersonName;
/** 楼层 */
@property (copy, nonatomic) NSString *floor;
/** 报修项目 */
@property (copy, nonatomic) NSString *fixProject;
/** 约定时间 */
@property (assign, nonatomic) NSInteger appointTime;
/** 维修师傅 */
@property (copy, nonatomic) NSString *masterPersonName;
/** 维修师傅电话 */
@property (copy, nonatomic) NSString *phone;
/** 上门时间 */
@property (assign, nonatomic) NSInteger doorTime;
/** 订单状态 */
@property (copy, nonatomic) NSString *status;
/** 问题描述 */
@property (copy, nonatomic) NSString *problemDesc;
/** 图片列表 */
@property (copy, nonatomic) NSArray *pictures;
/** 订单号 */
@property (copy,nonatomic) NSString *propertyNum;
/** 费用 */
@property (assign,nonatomic) CGFloat totalFee;

@end
