//
//  TCBlurImageView.h
//  individual
//
//  Created by 王帅锋 on 16/12/21.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MyBlock)();

@interface TCBlurImageView : UIImageView

- (instancetype)initWithController:(UIViewController *)controller endBlock:(MyBlock)b;
- (void)show;
@end
