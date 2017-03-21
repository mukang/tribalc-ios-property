//
//  TCBioEditEmotionViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBaseViewController.h"
#import "TCBuluoApi.h"

typedef void(^TCBioEditEmotionBlock)();

@interface TCBioEditEmotionViewController : TCBaseViewController

@property (nonatomic) TCUserEmotionState emotionState;
@property (copy, nonatomic) TCBioEditEmotionBlock editEmotionBlock;

@end
