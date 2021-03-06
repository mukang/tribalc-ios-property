//
//  TCPaymentViewController.h
//  individual
//
//  Created by 王帅锋 on 16/12/19.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>

typedef void(^ConfirmMoneySuccessBlock)();

@interface TCPaymentViewController : TCBaseViewController

@property (nonatomic, copy) NSString *orderID;

@property (copy, nonatomic) ConfirmMoneySuccessBlock successBlock;

@end
