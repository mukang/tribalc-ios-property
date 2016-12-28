//
//  TCPayMethodView.m
//  individual
//
//  Created by WYH on 16/12/12.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPayMethodView.h"
#import "TCComponent.h"

@implementation TCPayMethodView {
    UIButton *balanceBtn;
    UIButton *weChatPayBtn;
    UIButton *aliPayBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *payMethodLab = [TCComponent createLabelWithFrame:CGRectMake(TCRealValue(20), 0, TCScreenWidth - TCRealValue(40), TCRealValue(40)) AndFontSize:TCRealValue(12) AndTitle:@"支付方式"];
        [self addSubview:payMethodLab];
        
        UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), payMethodLab.y + payMethodLab.height - TCRealValue(0.5), TCScreenWidth - TCRealValue(40), TCRealValue(0.5))];
        [self addSubview:topLineView];
        
        UIButton *balanceView = [self getPayViewWithImageName:@"car_balance_pay" AndTitle:@"余额支付" AndFrame:CGRectMake(0, payMethodLab.y + payMethodLab.height, payMethodLab.width, payMethodLab.height)];
        balanceView.tag = 0;
        [self addSubview:balanceView];
        balanceBtn = [self getPaySelectBtnWithFrame:CGRectMake(TCScreenWidth - TCRealValue(20) - TCRealValue(16.5), payMethodLab.y + payMethodLab.height + balanceView.height / 2 - TCRealValue(16.5) / 2, TCRealValue(16.5), TCRealValue(16.5)) AndTitle:@"余额支付" AndTag:0];
        [balanceBtn setImage:[UIImage imageNamed:@"car_pay_selected"] forState:UIControlStateNormal];
        _selectPayMethodStr = @"余额";
        [self addSubview:balanceBtn];
        
        
        UIButton *weChatView = [self getPayViewWithImageName:@"car_wechat_pay" AndTitle:@"微信支付" AndFrame:CGRectMake(0, balanceView.y + balanceView.height, balanceView.width, balanceView.height)];
        weChatView.tag = 1;
        [self addSubview:weChatView];
        weChatPayBtn = [self getPaySelectBtnWithFrame:CGRectMake(TCScreenWidth - TCRealValue(20) - TCRealValue(16.5), balanceView.y + balanceView.height + payMethodLab.height / 2 - TCRealValue(16.5) / 2, TCRealValue(16.5), TCRealValue(16.5)) AndTitle:@"微信支付" AndTag:1];
        [self addSubview:weChatPayBtn];
        
        UIButton *aliPayView = [self getPayViewWithImageName:@"car_ali_pay" AndTitle:@"支付宝支付" AndFrame:CGRectMake(0, weChatView.y + weChatView.height, weChatView.width, weChatView.height)];
        aliPayView.tag = 2;
        [self addSubview:aliPayView];
        aliPayBtn = [self getPaySelectBtnWithFrame:CGRectMake(TCScreenWidth - TCRealValue(20) - TCRealValue(16.5), weChatView.y + weChatView.height + payMethodLab.height / 2 - TCRealValue(16.5) / 2, TCRealValue(16.5), TCRealValue(16.5)) AndTitle:@"支付宝支付" AndTag:2];
        [self addSubview:aliPayBtn];
        
        
    }
    
    return self;
}

- (UIButton *)getPayViewWithImageName:(NSString *)imgName AndTitle:(NSString *)title AndFrame:(CGRect)frame{
    UIButton *view = [[UIButton alloc] initWithFrame:frame];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(TCRealValue(30), frame.size.height / 2 - TCRealValue(18) / 2, TCRealValue(18), TCRealValue(18))];
    imgView.image = [UIImage imageNamed:imgName];
    [view addSubview:imgView];
    
    UILabel *titleLab = [TCComponent createLabelWithFrame:CGRectMake(imgView.x + imgView.width + TCRealValue(15), 0, TCRealValue(100), frame.size.height) AndFontSize:TCRealValue(12) AndTitle:title];
    [view addSubview:titleLab];
    
    UIView *lineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), frame.size.height - TCRealValue(0.5), TCScreenWidth - TCRealValue(40), TCRealValue(0.5))];
    [view addSubview:lineView];
    
    [view addTarget:self action:@selector(touchPaySelectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return view;
}


- (UIButton *)getPaySelectBtnWithFrame:(CGRect)frame AndTitle:(NSString *)title AndTag:(NSInteger)tag{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.tag = tag;
    button.userInteractionEnabled = YES;
    
    [button setImage:[UIImage imageNamed:@"car_unselected_pay"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchPaySelectButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)touchPaySelectButton:(UIButton *)button {
    NSInteger tag = button.tag;
    [balanceBtn setImage:[UIImage imageNamed:@"car_unselected_pay"] forState:UIControlStateNormal];
    [weChatPayBtn setImage:[UIImage imageNamed:@"car_unselected_pay"] forState:UIControlStateNormal];
    [aliPayBtn setImage:[UIImage imageNamed:@"car_unselected_pay"] forState:UIControlStateNormal];

    switch (tag) {
        case 0:
            [balanceBtn setImage:[UIImage imageNamed:@"car_pay_selected"] forState:UIControlStateNormal];
            self.selectPayMethodStr = @"余额";
            break;
        case 1:
            [weChatPayBtn setImage:[UIImage imageNamed:@"car_pay_selected"] forState:UIControlStateNormal];
            self.selectPayMethodStr = @"微信";
            break;
        case 2:
            [aliPayBtn setImage:[UIImage imageNamed:@"car_pay_selected"] forState:UIControlStateNormal];
            self.selectPayMethodStr = @"支付宝";
            break;
        default:
            break;
    }
}


@end
