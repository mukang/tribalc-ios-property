//
//  TCCommunity.h
//  individual
//
//  Created by 穆康 on 2016/11/28.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCommunity : NSObject

/** 社区ID */
@property (copy, nonatomic) NSString *ID;
/** 社区名称 */
@property (copy, nonatomic) NSString *name;
/** 详细地址 */
@property (copy, nonatomic) NSString *address;
/** 联系电话 */
@property (copy, nonatomic) NSString *phone;
/** 社区主图 */
@property (copy, nonatomic) NSString *mainPicture;
/** 城市 */
@property (copy, nonatomic) NSString *city;

@end
