//
//  TCCompanyListViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBaseViewController.h"
#import "TCCompanyInfo.h"
#import "TCCommunity.h"

typedef void(^TCCompanyInfoBlock)(TCCompanyInfo *companyInfo, TCCommunity *community);

@interface TCCompanyListViewController : TCBaseViewController

/** 社区ID */
@property (strong, nonatomic) TCCommunity *community;
@property (copy, nonatomic) TCCompanyInfoBlock companyInfoBlock;
@property (weak, nonatomic) UIViewController *popToVC;

@end
