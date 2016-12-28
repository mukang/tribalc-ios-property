//
//  TCBioEditGenderViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCBuluoApi.h"

typedef void(^TCBioEditGenderBlock)();

@interface TCBioEditGenderViewController : UIViewController

@property (nonatomic) TCUserGender gender;
@property (copy, nonatomic) TCBioEditGenderBlock editGenderBlock;

@end
