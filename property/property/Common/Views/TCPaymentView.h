//
//  TCPaymentView.h
//  individual
//
//  Created by 穆康 on 2016/12/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCWalletAccount.h"
@class TCPaymentView;

@protocol TCPaymentViewDelegate <NSObject>

@optional
- (void)paymentView:(TCPaymentView *)view didFinishedPaymentWithStatus:(NSString *)status;
- (void)didClickCloseButtonInPaymentView:(TCPaymentView *)view;

@end

@interface TCPaymentView : UIView

/** 商品订单ID数组（类型为商品时，必填） */
@property (copy, nonatomic) NSArray *orderIDs;
/** 钱包信息 */
@property (strong, nonatomic) TCWalletAccount *walletAccount;

@property (weak, nonatomic) id<TCPaymentViewDelegate> delegate;

/**
 指定初始化方法

 @param amount 付款金额
 @param controller 源控制器
 @return 返回TCPhotoPicker对象
 */
- (instancetype)initWithAmount:(CGFloat)amount fromController:(UIViewController *)controller;

/**
 显示付款页面

 @param animated 是否需要动画
 */
- (void)show:(BOOL)animated;

/**
 退出付款页面

 @param animated 是否需要动画
 */
- (void)dismiss:(BOOL)animated;

/**
 退出付款页面

 @param animated 是否需要动画
 @param completion 完成退出后的回调
 */
- (void)dismiss:(BOOL)animated completion:(void (^)())completion;

@end
