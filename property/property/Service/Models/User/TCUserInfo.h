//
//  TCUserInfo.h
//  individual
//
//  Created by 穆康 on 2016/11/10.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TCUserGender) {
    TCUserGenderUnknown,
    TCUserGenderMale,
    TCUserGenderFemale
};

typedef NS_ENUM(NSInteger, TCUserEmotionState) {
    TCUserEmotionStateUnknown,
    TCUserEmotionStateMarried,
    TCUserEmotionStateSingle,
    TCUserEmotionStateLove
};

@interface TCUserInfo : NSObject

/** 用户ID */
@property (copy, nonatomic) NSString *ID;
/** 注册时间 */
@property (nonatomic) NSInteger registrationDate;
/** 服务等级 */
@property (copy, nonatomic) NSString *serviceLeve;
/** 昵称 */
@property (copy, nonatomic) NSString *nickname;
/** 头像路径 */
@property (copy, nonatomic) NSString *picture;
/** 用户背景图 */
@property (copy, nonatomic) NSString *cover;
/** 性别(UNKNOWN, MALE, FEMALE) */
@property (copy, nonatomic) NSString *sex;
/** 性别(枚举) */
@property (nonatomic) TCUserGender gender;
/** 出生日期 */
@property (nonatomic) NSInteger birthday;
/** 情感状况(UNKNOWN, SINGLE, LOVE, MARRIED) */
@property (copy, nonatomic) NSString *emotion;
/** 情感状况(枚举) */
@property (nonatomic) TCUserEmotionState emotionState;
/** 所在省份 */
@property (copy, nonatomic) NSString *province;
/** 所在城市 */
@property (copy, nonatomic) NSString *city;
/** 所在城区 */
@property (copy, nonatomic) NSString *district;
/** 位置坐标 */
@property (copy, nonatomic) NSArray *coordinate;
/** 所在社区ID */
@property (copy, nonatomic) NSString *communityID;
/** 所在社区名称 */
@property (copy, nonatomic) NSString *communityName;

@end
