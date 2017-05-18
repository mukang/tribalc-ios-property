//
//  TCMyLockQRCodeController.h
//  individual
//
//  Created by 王帅锋 on 17/4/5.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <TCCommonLibs/TCBaseViewController.h>
@class TCMultiLockKey;

typedef NS_ENUM(NSInteger, TCQRCodeType) {
    TCQRCodeTypeSystem = 0,
    TCQRCodeTypeCustom
};

@interface TCMyLockQRCodeController : TCBaseViewController

@property (nonatomic, readonly) TCQRCodeType codeType;

@property (strong, nonatomic) TCMultiLockKey *multiLockKey;
@property (copy, nonatomic) NSArray *equipIDs;

- (instancetype)initWithLockQRCodeType:(TCQRCodeType)codeType;

@end
