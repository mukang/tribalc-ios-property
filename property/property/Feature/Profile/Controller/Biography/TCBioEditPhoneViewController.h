//
//  TCBioEditPhoneViewController.h
//  individual
//
//  Created by 穆康 on 2016/11/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCBioEditSMSViewController.h"

@interface TCBioEditPhoneViewController : UIViewController

/** 编辑新手机号回调 */
@property (copy, nonatomic) TCEditPhoneBlock editPhoneBlock;

@end
