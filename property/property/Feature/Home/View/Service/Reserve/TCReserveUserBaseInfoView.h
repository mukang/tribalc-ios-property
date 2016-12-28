//
//  TCReserveUserBaseInfoView.h
//  individual
//
//  Created by WYH on 16/12/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCReserveRadioBtnView.h"

@interface TCReserveUserBaseInfoView : UIView

@property (nonatomic) TCReserveRadioBtnView *senderView;
@property (nonatomic) UILabel *nameLab;
@property (nonatomic) UITextField *phoneTextField;
@property (nonatomic) UITextField *additionalTextField;
@property (nonatomic) UITextField *verificationCodeTextField;
@property (nonatomic) BOOL isNeedVerification;

@end
