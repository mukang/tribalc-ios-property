//
//  TCLockQRCodeViewController.h
//  individual
//
//  Created by 穆康 on 2017/3/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>
#import "TCLockQRCodeView.h"
@class TCMultiLockKey;

@interface TCLockQRCodeViewController : TCBaseViewController

@property (nonatomic, readonly) TCLockQRCodeType type;
@property (strong, nonatomic) TCMultiLockKey *lockKey;
@property (strong, nonatomic) NSString *equipID;

@property (weak, nonatomic) UIViewController *fromController;

- (instancetype)initWithLockQRCodeType:(TCLockQRCodeType)type;

@end
