//
//  TCCompanyApplyViewController.h
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>

typedef NS_ENUM(NSInteger, TCCompanyApplyStatus) {
    TCCompanyApplyStatusNotApply,
    TCCompanyApplyStatusProcess,
    TCCompanyApplyStatusFailure
};

@interface TCCompanyApplyViewController : TCBaseViewController

@property (nonatomic, readonly) TCCompanyApplyStatus applyStatus;

- (instancetype)initWithCompanyApplyStatus:(TCCompanyApplyStatus)applyStatus;

@end
