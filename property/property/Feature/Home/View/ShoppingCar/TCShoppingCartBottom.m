//
//  TCShoppingCartBottom.m
//  individual
//
//  Created by WYH on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShoppingCartBottom.h"

@implementation TCShoppingCartBottom {
    UILabel *totalTagLab;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _selectBtn = [[TCShoppingCartSelectButton alloc] initWithFrame:CGRectMake(0, 0, TCRealValue(56), self.height)];
        [self addSubview:_selectBtn];
        
        UILabel *allSelectTagLab = [[UILabel alloc] initWithFrame:CGRectMake(_selectBtn.x + _selectBtn.width, 0, TCRealValue(30), self.height)];
        allSelectTagLab.font = [UIFont systemFontOfSize:TCRealValue(14)];
        allSelectTagLab.text = @"全选";
        [self addSubview:allSelectTagLab];
        
        _deleteButton = [self getButtonWithFrame:CGRectMake(TCScreenWidth - TCRealValue(111), 0, TCRealValue(111), self.height) AndTitle:@"删除"];
        [self addSubview:_deleteButton];
        
        _payButton = [self getButtonWithFrame:_deleteButton.frame AndTitle:@"结算"];
        [self addSubview:_payButton];
        
        totalTagLab = [ [UILabel alloc] initWithFrame:CGRectMake(TCRealValue(99), self.height / 2 - TCRealValue(14) / 2 - TCRealValue(2), TCRealValue(45), TCRealValue(16))];
        totalTagLab.font = [UIFont systemFontOfSize:TCRealValue(16)];
        totalTagLab.text = @"合计 :";
        [self addSubview:totalTagLab];
        
        _totalLab = [[UILabel alloc] initWithFrame:CGRectMake(totalTagLab.x + totalTagLab.width, 0, TCScreenWidth - TCRealValue(111) - totalTagLab.x - totalTagLab.width, self.height)];
        _totalLab.font = [UIFont systemFontOfSize:TCRealValue(14)];
        _totalLab.textColor = [UIColor redColor];
        _totalLab.text = @"￥0";
        [self addSubview:_totalLab];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth, 0.5)];
        topLine.backgroundColor = TCRGBColor(224, 224, 224);
        [self addSubview:topLine];
        
        _isEdit = NO;

    }
    
    return self;
}

- (UIButton *)getButtonWithFrame:(CGRect)frame AndTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = TCRGBColor(81, 199, 209);
    button.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(14)];
    return button;
}



- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    if (_isEdit) {
        _deleteButton.hidden = NO;
        _payButton.hidden = YES;
        totalTagLab.hidden = YES;
        _totalLab.hidden = YES;
    } else {
        _deleteButton.hidden = YES;
        _payButton.hidden = NO;
        totalTagLab.hidden = NO;
        _totalLab.hidden = NO;
    }
}

@end
