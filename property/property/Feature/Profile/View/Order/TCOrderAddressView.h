//
//  TCOrderAddressView.h
//  individual
//
//  Created by WYH on 16/11/26.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCComponent.h"
#import "TCModelImport.h"


@interface TCOrderAddressView : UIView

- (instancetype)initWithOrigin:(CGPoint)point AndName:(NSString *)name AndPhone:(NSString *)phone AndAddress:(NSString *)address;

- (instancetype)initWithOrigin:(CGPoint)point WithShippingAddress:(TCUserShippingAddress *)shippingAddress;

- (void)setAddress:(TCUserShippingAddress *)shippingAddress;

@property (retain, nonatomic) TCUserShippingAddress *shippingAddress;

@end
