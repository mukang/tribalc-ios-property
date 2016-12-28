//
//  TCBioEditBirthdateViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TCBioEditBirthdateBlock)();

@interface TCBioEditBirthdateViewController : UIViewController

@property (strong, nonatomic) NSDate *birthdate;
@property (copy, nonatomic) TCBioEditBirthdateBlock editBirthdateBlock;

@end
