//
//  TCShoppingCartBottom.h
//  individual
//
//  Created by WYH on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCShoppingCartSelectButton.h"

@interface TCShoppingCartBottom : UIView

@property (nonatomic) TCShoppingCartSelectButton *selectBtn;

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic) UIButton *payButton;

@property (nonatomic) UIButton *deleteButton;

@property (nonatomic) UILabel *totalLab;

@end
