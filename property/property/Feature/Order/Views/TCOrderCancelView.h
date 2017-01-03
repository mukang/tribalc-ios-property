//
//  TCOrderCancelView.h
//  property
//
//  Created by 王帅锋 on 17/1/3.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelBlock)();
typedef void(^ConfirmBlock)(NSString *);

@interface TCOrderCancelView : UIView

@property (copy, nonatomic) CancelBlock cancelBlock;

@property (copy, nonatomic) ConfirmBlock confirmBlock;

@end
