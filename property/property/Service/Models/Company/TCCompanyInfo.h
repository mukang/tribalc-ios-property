//
//  TCCompanyInfo.h
//  individual
//
//  Created by 穆康 on 2016/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCCompanyInfo : NSObject

/** 公司ID */
@property (copy, nonatomic) NSString *ID;
/** 公司图组 */
@property (copy, nonatomic) NSArray *pictures;
/** 公司logo */
@property (copy, nonatomic) NSString *logo;
/** 公司名称 */
@property (copy, nonatomic) NSString *companyName;
/** 公司简介 */
@property (copy, nonatomic) NSString *desc;

@end
