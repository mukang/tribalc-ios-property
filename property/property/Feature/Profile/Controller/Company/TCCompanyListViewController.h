//
//  TCCompanyListViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCCompanyInfo;

typedef void(^TCCompanyInfoBlock)(TCCompanyInfo *companyInfo);

@interface TCCompanyListViewController : UIViewController

/** 社区ID */
@property (copy, nonatomic) NSString *communityID;
@property (copy, nonatomic) TCCompanyInfoBlock companyInfoBlock;
@property (weak, nonatomic) UIViewController *popToVC;

@end
