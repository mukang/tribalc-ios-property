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
/** logo */
@property (copy, nonatomic) NSString *logo;
/** 昵称 */
@property (copy, nonatomic) NSString *nickname;
/** 物业人员姓名 */
@property (copy, nonatomic) NSString *name;
/** 电话 */
@property (copy, nonatomic) NSString *phone;
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
/** 街区 */
@property (copy, nonatomic) NSString *district;
/** 背景图片 */
@property (copy, nonatomic) NSString *cover;
/** 头像 */
@property (copy, nonatomic) NSString *picture;
/** 身份证号 */
@property (copy, nonatomic) NSString *idNo;
/** 认证状态(PROCESSING, SUCCESS, FAILURE) */
@property (copy, nonatomic) NSString *authorizedStatus;

@end
