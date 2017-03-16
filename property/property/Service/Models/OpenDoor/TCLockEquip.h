//
//  TCLockEquip.h
//  individual
//
//  Created by 王帅锋 on 17/3/10.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCLockEquip : NSObject

@property (copy, nonatomic) NSString *ID;

@property (copy, nonatomic) NSString *communityId;

@property (copy, nonatomic) NSString *managerId;

@property (assign, nonatomic) NSInteger createTime;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *desc;

@property (copy, nonatomic) NSArray *activityTime;

@property (assign, nonatomic) BOOL actived;

@end
