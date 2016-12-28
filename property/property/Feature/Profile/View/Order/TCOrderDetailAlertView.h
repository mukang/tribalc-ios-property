//
//  TCOrderDetailAlertView.h
//  individual
//
//  Created by WYH on 16/12/11.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCOrderDetailAlertView;

@protocol TCOrderDetailAlertViewDelegate <NSObject>

- (void)alertView:(TCOrderDetailAlertView *)alertView didSelectOptionButtonWithTag:(NSInteger)tag;

@end


@interface TCOrderDetailAlertView : UIView

@property (nonatomic, weak) id<TCOrderDetailAlertViewDelegate> delegate;

- (void)show;
- (void)dismiss;

@end
