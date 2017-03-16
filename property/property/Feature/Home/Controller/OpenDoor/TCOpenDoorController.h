//
//  TCOpenDoorController.h
//  individual
//
//  Created by 王帅锋 on 16/12/20.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Myblock)();

@interface TCOpenDoorController : UIViewController

@property (nonatomic, copy) Myblock myBlock;

@end
