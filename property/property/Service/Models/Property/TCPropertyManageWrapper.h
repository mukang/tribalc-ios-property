//
//  TCPropertyManageWrapper.h
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPropertyManageWrapper : NSObject

/** 当前查询状态 */
@property (copy, nonatomic) NSString *status;
/** 当前结果中的前置跳过 */
@property (copy, nonatomic) NSString *prevSkip;
/** 当前结果中的最后跳过规则，可用于下次查询 */
@property (copy, nonatomic) NSString *nextSkip;
/** 是否还有条目待获取 */
@property (nonatomic) BOOL hasMore;
/** 明细列表 */
@property (copy, nonatomic) NSArray *content;
/** 排序 */
@property (copy, nonatomic) NSString *sort;

@end
