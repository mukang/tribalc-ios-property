//
//  TCShoppingCartSelectButton.m
//  individual
//
//  Created by WYH on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShoppingCartSelectButton.h"

@implementation TCShoppingCartSelectButton {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setImage:[UIImage imageNamed:@"car_unselected"] forState:UIControlStateNormal];
        _isSelected = NO;
        _hiddenSelectButton = NO;
    }
    
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self setImage:[UIImage imageNamed:@"car_selected"] forState:UIControlStateNormal];
    } else {
        [self setImage:[UIImage imageNamed:@"car_unselected"] forState:UIControlStateNormal];
    }
}

- (void)setHiddenSelectButton:(BOOL)hiddenSelectButton {
    _hiddenSelectButton = hiddenSelectButton;
    if (hiddenSelectButton) {
        [self setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    } else {
        if (_isSelected) {
            [self setImage:[UIImage imageNamed:@"car_selected"] forState:UIControlStateNormal];
        } else {
            [self setImage:[UIImage imageNamed:@"car_unselected"] forState:UIControlStateNormal];
        }
    }
}

@end
