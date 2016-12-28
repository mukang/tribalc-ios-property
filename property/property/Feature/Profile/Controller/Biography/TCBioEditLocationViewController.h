//
//  TCBioEditLocationViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCBuluoApi.h"

typedef void(^TCBioEditLocationBlock)();

@interface TCBioEditLocationViewController : UIViewController

@property (strong, nonatomic) TCUserAddress *address;
@property (copy, nonatomic) TCBioEditLocationBlock editLocationBlock;

@end
