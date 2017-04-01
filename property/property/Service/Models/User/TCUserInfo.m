//
//  TCUserInfo.m
//  individual
//
//  Created by 穆康 on 2016/11/10.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserInfo.h"
#import <TCCommonLibs/NSObject+TCModel.h>

@implementation TCUserInfo

- (void)setSex:(NSString *)sex {
    _sex = sex;
    if ([sex isEqualToString:@"MALE"]) {
        self.gender = TCUserGenderMale;
    } else if ([sex isEqualToString:@"FEMALE"]) {
        self.gender = TCUserGenderFemale;
    } else {
        self.gender = TCUserGenderUnknown;
    }
}

- (void)setEmotion:(NSString *)emotion {
    _emotion = emotion;
    if ([emotion isEqualToString:@"SINGLE"]) {
        self.emotionState = TCUserEmotionStateSingle;
    } else if ([emotion isEqualToString:@"MARRIED"]) {
        self.emotionState = TCUserEmotionStateMarried;
    } else if ([emotion isEqualToString:@"LOVE"]) {
        self.emotionState = TCUserEmotionStateLove;
    } else {
        self.emotionState = TCUserEmotionStateUnknown;
    }
}

@end
