//
//  TCPaymentDetailView.h
//  individual
//
//  Created by 穆康 on 2016/12/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCPaymentDetailView;

@protocol TCPaymentDetailViewDelegate <NSObject>

@optional
- (void)didClickConfirmButtonInPaymentDetailView:(TCPaymentDetailView *)view;
- (void)didClickCloseButtonInPaymentDetailView:(TCPaymentDetailView *)view;
- (void)didClickQueryButtonInPaymentDetailView:(TCPaymentDetailView *)view;

@end

@interface TCPaymentDetailView : UIView

@property (nonatomic) CGFloat paymentAmount;

@property (weak, nonatomic) id<TCPaymentDetailViewDelegate> delegate;

@end
