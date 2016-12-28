//
//  TCOrderDetailAlertView.m
//  individual
//
//  Created by WYH on 16/12/11.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCOrderDetailAlertView.h"
#import "TCComponent.h"

@implementation TCOrderDetailAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backView.backgroundColor = [UIColor blackColor];
        backView.alpha = 0.7;
        UITapGestureRecognizer *tapGesturecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackView)];
        [backView addGestureRecognizer:tapGesturecognizer];
        [self addSubview:backView];
        
        UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth - TCRealValue(40) * 2, (TCScreenWidth - TCRealValue(40) * 1.7) / 2)];
        alertView.center = CGPointMake(self.center.x, self.center.y);
        alertView.contentMode = UIViewContentModeScaleToFill;
        alertView.userInteractionEnabled = YES;
        alertView.backgroundColor = [UIColor whiteColor];
        
        
        UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TCRealValue(16), TCRealValue(16))];
        tagImageView.image = [UIImage imageNamed:@"reserve_fail"];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alertView.width, alertView.height - TCRealValue(50))];
        titleLab.text = @"是否确定取消订单";
        [titleLab sizeToFit];
        tagImageView.frame = CGRectMake(alertView.width / 2 - (tagImageView.width + titleLab.width) / 2, (alertView.height - TCRealValue(50)) / 2 - TCRealValue(16) / 2, TCRealValue(16), TCRealValue(16));
        titleLab.frame = CGRectMake(tagImageView.x + tagImageView.width, tagImageView.y, titleLab.width, TCRealValue(16));
        [alertView addSubview:tagImageView];
        [alertView addSubview:titleLab];
        
        UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(0, alertView.height - TCRealValue(50), alertView.width, TCRealValue(1))];
        [alertView addSubview:topLineView];
        
        UIView *centerLineView = [TCComponent createGrayLineWithFrame:CGRectMake(alertView.width / 2 - TCRealValue(0.5), alertView.height - TCRealValue(50) + TCRealValue(6), TCRealValue(1), TCRealValue(50 - 12))];
        [alertView addSubview:centerLineView];
        
        UIButton *cancelBtn = [self getButtonWithText:@"取消" AndFrame:CGRectMake(0, topLineView.y + topLineView.height, centerLineView.x, TCRealValue(50))];
        cancelBtn.tag = 0;
        [cancelBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:cancelBtn];
        
        UIButton *confirmBtn = [self getButtonWithText:@"确定" AndFrame:CGRectMake(cancelBtn.width + TCRealValue(1), cancelBtn.y, cancelBtn.width, cancelBtn.height)];
        confirmBtn.tag = 1;
        [confirmBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:confirmBtn];
        
        [self addSubview:alertView];
        
    }
    
    return self;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];

}

- (void)dismiss
{
    [self removeFromSuperview];
}



- (void)btnOnClick:(UIButton *) button{
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:didSelectOptionButtonWithTag:)]) {
        [_delegate alertView:self didSelectOptionButtonWithTag:button.tag];
    }
}

- (void)touchBackView {
    [self removeFromSuperview];
}

- (UIButton *)getButtonWithText:(NSString *)text AndFrame:(CGRect)frame{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:TCRGBColor(81, 199, 209) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(16)];
    
    return button;
}

@end
