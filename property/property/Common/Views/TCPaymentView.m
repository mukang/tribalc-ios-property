//
//  TCPaymentView.m
//  individual
//
//  Created by 穆康 on 2016/12/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPaymentView.h"
#import "TCPaymentDetailView.h"
#import "TCPaymentPasswordView.h"
#import "TCBuluoApi.h"
#import "TCFunctions.h"

static CGFloat const subviewHeight = 400;
static CGFloat const duration = 0.25;

@interface TCPaymentView () <TCPaymentDetailViewDelegate, TCPaymentPasswordViewDelegate>

@property (nonatomic) CGFloat paymentAmount;
@property (weak, nonatomic) TCPaymentDetailView *paymentDetailView;
@property (weak, nonatomic) TCPaymentPasswordView *paymentPasswordView;

@end

@implementation TCPaymentView {
    __weak TCPaymentView *weakSelf;
    __weak UIViewController *sourceController;
}

- (instancetype)initWithAmount:(CGFloat)amount fromController:(UIViewController *)controller {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        weakSelf = self;
        sourceController = controller;
        _paymentAmount = amount;
        [self initPrivate];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    @throw [NSException exceptionWithName:@"TCPaymentView初始化错误"
                                   reason:@"请使用接口文件提供的初始化方法"
                                 userInfo:nil];
    return nil;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"TCPaymentView初始化错误"
                                   reason:@"请使用接口文件提供的初始化方法"
                                 userInfo:nil];
    return nil;
}

- (void)initPrivate {
    self.backgroundColor = TCARGBColor(0, 0, 0, 0);
    
    TCPaymentDetailView *paymentDetailView = [[NSBundle mainBundle] loadNibNamed:@"TCPaymentDetailView" owner:nil options:nil].lastObject;
    paymentDetailView.paymentAmount = _paymentAmount;
    paymentDetailView.delegate = self;
    paymentDetailView.frame = CGRectMake(0, TCScreenHeight, TCScreenWidth, subviewHeight);
    [self addSubview:paymentDetailView];
    self.paymentDetailView = paymentDetailView;
}

#pragma mark - Public Methods

- (void)show:(BOOL)animated {
    if (!sourceController) return;
    
    UIView *superView;
    if (sourceController.navigationController) {
        superView = sourceController.navigationController.view;
    } else {
        superView = sourceController.view;
    }
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            weakSelf.backgroundColor = TCARGBColor(0, 0, 0, 0.62);
            weakSelf.paymentDetailView.y = TCScreenHeight - subviewHeight;
        }];
    } else {
        weakSelf.backgroundColor = TCARGBColor(0, 0, 0, 0.62);
        weakSelf.paymentDetailView.y = TCScreenHeight - subviewHeight;
    }
}

- (void)dismiss:(BOOL)animated {
    [self dismiss:animated completion:nil];
}

- (void)dismiss:(BOOL)animated completion:(void (^)())completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            weakSelf.backgroundColor = TCARGBColor(0, 0, 0, 0);
            weakSelf.paymentDetailView.y = TCScreenHeight;
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
            if (completion) {
                completion();
            }
        }];
    } else {
        weakSelf.backgroundColor = TCARGBColor(0, 0, 0, 0);
        weakSelf.paymentDetailView.y = TCScreenHeight;
        [weakSelf removeFromSuperview];
        if (completion) {
            completion();
        }
    }
}

#pragma mark - Private Methods

/**
 显示输入密码页
 */
- (void)showPaymentPasswordView {
    TCPaymentPasswordView *paymentPasswordView = [[NSBundle mainBundle] loadNibNamed:@"TCPaymentPasswordView" owner:nil options:nil].lastObject;
    paymentPasswordView.frame = CGRectMake(TCScreenWidth, self.paymentDetailView.y, TCScreenWidth, subviewHeight);
    paymentPasswordView.delegate = self;
    paymentPasswordView.textField.centerX = paymentPasswordView.width / 2;
    [self addSubview:paymentPasswordView];
    self.paymentPasswordView = paymentPasswordView;
    
    [UIView animateWithDuration:duration animations:^{
        weakSelf.paymentDetailView.x = - TCScreenWidth;
        weakSelf.paymentPasswordView.x = 0;
    } completion:^(BOOL finished) {
        [weakSelf.paymentPasswordView.textField becomeFirstResponder];
    }];
}

/**
 退出输入密码页
 */
- (void)dismissPaymentPasswordView {
    [UIView animateWithDuration:duration animations:^{
        weakSelf.paymentDetailView.x = 0;
        weakSelf.paymentPasswordView.x = TCScreenWidth;
    } completion:^(BOOL finished) {
        [weakSelf.paymentPasswordView removeFromSuperview];
    }];
}

#pragma mark - TCPaymentDetailViewDelegate

- (void)didClickConfirmButtonInPaymentDetailView:(TCPaymentDetailView *)view {
    [weakSelf showPaymentPasswordView];
}

- (void)didClickCloseButtonInPaymentDetailView:(TCPaymentDetailView *)view {
    [self dismiss:YES completion:^{
        if ([weakSelf.delegate respondsToSelector:@selector(didClickCloseButtonInPaymentView:)]) {
            [weakSelf.delegate didClickCloseButtonInPaymentView:self];
        }
    }];
}

- (void)didClickQueryButtonInPaymentDetailView:(TCPaymentDetailView *)view {
    TCLog(@"点击了疑问按钮");
}

#pragma mark - TCPaymentPasswordViewDelegate

- (void)paymentPasswordView:(TCPaymentPasswordView *)view didFilledPassword:(NSString *)password {
    [self handlePaymentWithPassword:password];
}

- (void)didClickBackButtonInPaymentPasswordView:(TCPaymentPasswordView *)view {
    [self dismissPaymentPasswordView];
}

#pragma mark - Actions

/**
 提交付款申请
 */
- (void)handlePaymentWithPassword:(NSString *)password {
    if (![TCDigestMD5(password) isEqualToString:self.walletAccount.password]) {
        [MBProgressHUD showHUDWithMessage:@"付款失败，密码错误"];
        return;
    }
    if (self.paymentAmount > self.walletAccount.balance) {
        [MBProgressHUD showHUDWithMessage:@"付款失败，您的钱包余额不足"];
        return;
    }
    
    [MBProgressHUD showHUD:YES];
//    [[TCBuluoApi api] commitPaymentWithPayChannel:TCPayChannelBalance orderIDs:self.orderIDs result:^(TCUserPayment *userPayment, NSError *error) {
//        if (userPayment) {
//            if ([userPayment.status isEqualToString:@"CREATED"]) { // 正在处理中
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [weakSelf handleQueryPaymentStatusWithPaymentID:userPayment.ID];
//                });
//            } else if ([userPayment.status isEqualToString:@"FAILURE"]) { // 错误（余额不足）
//                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"付款失败，%@", userPayment.note]];
//            } else { // 付款成功
//                [MBProgressHUD hideHUD:YES];
//                [weakSelf dismiss:YES completion:^{
//                    if ([weakSelf.delegate respondsToSelector:@selector(paymentView:didFinishedPaymentWithStatus:)]) {
//                        [weakSelf.delegate paymentView:weakSelf didFinishedPaymentWithStatus:userPayment.status];
//                    }
//                }];
//            }
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"付款失败，%@", reason]];
//        }
//    }];
}

/**
 查询付款状态
 */
- (void)handleQueryPaymentStatusWithPaymentID:(NSString *)paymentID {
//    [[TCBuluoApi api] fetchUserPayment:paymentID result:^(TCUserPayment *userPayment, NSError *error) {
//        if (userPayment) {
//            if ([userPayment.status isEqualToString:@"FAILURE"]) {
//                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"付款失败，%@", userPayment.note]];
//            } else {
//                [MBProgressHUD hideHUD:YES];
//                [weakSelf dismiss:YES completion:^{
//                    if ([weakSelf.delegate respondsToSelector:@selector(paymentView:didFinishedPaymentWithStatus:)]) {
//                        [weakSelf.delegate paymentView:weakSelf didFinishedPaymentWithStatus:userPayment.status];
//                    }
//                }];
//            }
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"付款失败，%@", reason]];
//        }
//    }];
}

@end
