//
//  TCReserveRadioBtnView.m
//  individual
//
//  Created by WYH on 16/12/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCReserveRadioBtnView.h"

@implementation TCReserveRadioBtnView {
    UIButton *leftBtn;
    UIButton *rightBtn;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        leftBtn = [TCComponent createImageBtnWithFrame:CGRectMake(0, frame.size.height / 2 - TCRealValue(15) / 2, TCRealValue(15), TCRealValue(15)) AndImageName:@"car_unselected"];
        [leftBtn addTarget:self action:@selector(touchSelectLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        
        UILabel *leftLab = [TCComponent createLabelWithFrame:CGRectMake(leftBtn.x + leftBtn.width + TCRealValue(3), 0, TCRealValue(30), self.height) AndFontSize:TCRealValue(14) AndTitle:@"女士"];
        [self addSubview:leftLab];
//        _selectStr = @"女士";
        
        rightBtn = [TCComponent createImageBtnWithFrame:CGRectMake(leftLab.x + leftLab.width + TCRealValue(13.5), leftBtn.y, leftBtn.width, leftBtn.height) AndImageName:@"car_unselected"];
        [rightBtn addTarget:self action:@selector(touchSelectRightBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        
        UILabel *rightLab = [TCComponent createLabelWithFrame:CGRectMake(rightBtn.x + rightBtn.width + TCRealValue(3), 0, TCRealValue(30), self.height) AndFontSize:TCRealValue(14) AndTitle:@"男士"];
        [self addSubview:rightLab];
        
    }
    
    return self;
}



- (void)touchSelectLeftBtn:(UIButton *)btn {
    [leftBtn setImage:[UIImage imageNamed:@"car_selected"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"car_unselected"] forState:UIControlStateNormal];
    _selectStr = @"女士";
}

- (void)touchSelectRightBtn:(UIButton *)btn {
    [rightBtn setImage:[UIImage imageNamed:@"car_selected"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"car_unselected"] forState:UIControlStateNormal];
    _selectStr = @"男士";
}


@end
