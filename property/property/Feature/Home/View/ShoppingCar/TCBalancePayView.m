//
//  TCBalancePayView.m
//  individual
//
//  Created by WYH on 16/12/12.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBalancePayView.h"
#import "TCComponent.h"

@implementation TCBalancePayView {
    UIView *payView;
}

- (instancetype)initWithPayPrice:(NSString *)priceStr AndPayAction:(SEL)payAction AndCloseAction:(SEL)closeAction AndTarget:(id)target{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self addSubview:backView];
        
        [self initPayViewWithPrice:priceStr AndPayAction:payAction AndCloseAction:closeAction AndTarget:target ];
    }
    
    return self;
}

- (void)initPayViewWithPrice:(NSString *)priceStr AndPayAction:(SEL)payAction AndCloseAction:(SEL)closeAction AndTarget:(id)target {
    payView = [[UIView alloc] initWithFrame:CGRectMake(0, TCScreenHeight, TCScreenWidth, 398)];
    payView.backgroundColor = [UIColor whiteColor];
    [self addSubview:payView];
    
    UIView *titleView = [self getTitleViewWithFrame:CGRectMake(0, 0, TCScreenWidth, 62) AndCloseAction:closeAction  AndTarget:target];
    [payView addSubview:titleView];
    
    UIView *payMethodView = [self getPayMethodViewWithFrame:CGRectMake(0, titleView.y + titleView.height, TCScreenWidth, 62)];
    [payView addSubview:payMethodView];
    
    UIView *priceView = [self getPayPriceViewWithFrame:CGRectMake(0, payMethodView.y + payMethodView.height, TCScreenWidth, payView.height - payMethodView.y - payMethodView.height) AndPrice:priceStr];
    [payView addSubview:priceView];
    
    UIButton *confirmBtn = [self getConfirmButtonWithFrame:CGRectMake(TCScreenWidth / 2 - 315 / 2, payView.height - 38 - 40, 315, 40)];
    [confirmBtn addTarget:target action:payAction forControlEvents:UIControlEventTouchUpInside];
    [payView addSubview:confirmBtn];
}

- (void)showPayView {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.15 animations:^(void) {
        payView.y = TCScreenHeight - 398;
    }];
}

- (UIButton *)getConfirmButtonWithFrame:(CGRect)frame {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = TCRGBColor(81, 199, 209);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.layer.cornerRadius = 5;
    [button setTitle:@"确认支付" forState:UIControlStateNormal];
    
    return button;
    
}

- (UIView *)getPayPriceViewWithFrame:(CGRect)frame AndPrice:(NSString *)priceStr{
    UIView *priceView = [[UIView alloc] initWithFrame:frame];
    UILabel *priceTagLab = [TCComponent createLabelWithFrame:CGRectMake(20, frame.size.height - 204 - 14, 15 * 3, 14) AndFontSize:14 AndTitle:@"需付款"];
    [priceView addSubview:priceTagLab];
    
    UILabel *priceLab = [self getPriceLabelWithText:priceStr AndFrame:CGRectMake(priceTagLab.x + priceTagLab.width + 3, priceTagLab.y, TCScreenWidth - 33 - priceTagLab.x - priceTagLab.width - 3, 20)];
    [priceView addSubview:priceLab];
    
    return priceView;
}

- (UILabel *)getPriceLabelWithText:(NSString *)text AndFrame:(CGRect)frame{
    UILabel *label = [TCComponent createLabelWithText:text AndFontSize:20 AndTextColor:[UIColor blackColor]];
    label.font = [UIFont fontWithName:BOLD_FONT size:20];
    label.textAlignment = NSTextAlignmentRight;
    label.frame = frame;
    
    return label;
}

- (UIView *)getPayMethodViewWithFrame:(CGRect)frame {
    UIView *payMethodView = [[UIView alloc] initWithFrame:frame];
    UILabel *payMethodTagLab = [self getPayMethodLabelWithFrame:CGRectMake(20, 0, 15 * 4, frame.size.height) AndText:@"付款方式"];
    [payMethodView addSubview:payMethodTagLab];
    UILabel *payMethodLab = [self getPayMethodLabelWithFrame:CGRectMake(TCScreenWidth - 40 - 15 * 4, payMethodTagLab.y, 15 * 4, payMethodTagLab.height) AndText:@"余额支付"];
    [payMethodView addSubview:payMethodLab];
    
    UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(20, 0, TCScreenWidth - 40, 0.5)];
    UIView *downLineView = [TCComponent createGrayLineWithFrame:CGRectMake(20, frame.size.height - 0.5, TCScreenWidth - 40, 0.5)];
    [payMethodView addSubview:topLineView];
    [payMethodView addSubview:downLineView];
    
    return payMethodView;
}

- (UILabel *)getPayMethodLabelWithFrame:(CGRect)frame AndText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = TCRGBColor(154, 154, 154);
    
    return label;
}

- (UIView *)getTitleViewWithFrame:(CGRect)frame AndCloseAction:(SEL)closeAction AndTarget:(id)target{
    UIView *titleView = [[UIView alloc] initWithFrame:frame];
    UILabel *titleLab = [TCComponent createLabelWithFrame:CGRectMake(25, 0, frame.size.width - 50, frame.size.height) AndFontSize:17 AndTitle:@"付款详情"];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:titleLab];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, frame.size.height / 2 - 19 / 2, 19, 19)];
    [closeBtn setImage:[UIImage imageNamed:@"car_close_btn"] forState:UIControlStateNormal];
    [closeBtn addTarget:target action:closeAction forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeBtn];
    
    UIButton *questionBtn = [[UIButton alloc] initWithFrame:CGRectMake(TCScreenWidth - 20 - 19, closeBtn.y, 19, 19)];
    [questionBtn setImage:[UIImage imageNamed:@"car_question_btn"] forState:UIControlStateNormal];
    [titleView addSubview:questionBtn];
    
    
    return  titleView;
}


- (void)touchCloseBtn {
    [self removeFromSuperview];
}


@end
