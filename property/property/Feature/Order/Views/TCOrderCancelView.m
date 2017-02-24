//
//  TCOrderCancelView.m
//  property
//
//  Created by 王帅锋 on 17/1/3.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCOrderCancelView.h"
#import "TCCommonButton.h"

@interface TCOrderCancelView ()

@property (nonatomic, strong) UIImageView *applyImageView;

@property (nonatomic, strong) UIImageView *masterImageView;

@property (nonatomic, strong) UIButton *applyBtn;

@property (nonatomic, strong) UIButton *masterBtn;

@end

@implementation TCOrderCancelView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews {
    self.backgroundColor = [UIColor colorWithRed:86/255.0 green:87/255.0 blue:88/255.0 alpha:0.8];
    
    UIView *whiteView = [[UIView alloc] init];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 3.0;
    whiteView.clipsToBounds = YES;
    [self addSubview:whiteView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"取消原因";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = TCRGBColor(42, 42, 42);
    [whiteView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TCRGBColor(154, 154, 154);
    [whiteView addSubview:lineView];
    
    _applyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [whiteView addSubview:_applyBtn];
    [_applyBtn addTarget:self action:@selector(applyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _applyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unSelected"]];
    [_applyBtn addSubview:_applyImageView];
    
    UILabel *applyLabel = [[UILabel alloc] init];
    applyLabel.textColor = TCRGBColor(42, 42, 42);
    applyLabel.text = @"报修者要取消订单";
    applyLabel.font = [UIFont systemFontOfSize:14];
    [_applyBtn addSubview:applyLabel];
    
    _masterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [whiteView addSubview:_masterBtn];
    [_masterBtn addTarget:self action:@selector(masterBtnClick) forControlEvents:UIControlEventTouchUpInside];

    
    _masterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unSelected"]];
    [_masterBtn addSubview:_masterImageView];
    
    UILabel *masterLabel = [[UILabel alloc] init];
    masterLabel.textColor = TCRGBColor(42, 42, 42);
    masterLabel.text = @"维修师傅要取消订单";
    masterLabel.font = [UIFont systemFontOfSize:14];
    [_masterBtn addSubview:masterLabel];
    
    TCCommonButton *cancelBtn = [TCCommonButton buttonWithTitle:@"取 消" target:self action:@selector(cancelOrder)];
    [whiteView addSubview:cancelBtn];
    
    TCCommonButton *confirmBtn = [TCCommonButton buttonWithTitle:@"确 定" target:self action:@selector(confirmOrder)];
    [whiteView addSubview:confirmBtn];
    
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(TCRealValue(20));
        make.top.equalTo(self).offset(TCRealValue(214));
        make.right.equalTo(self).offset(-TCRealValue(20));
        make.height.equalTo(@(TCRealValue(180)));
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(whiteView);
        make.height.equalTo(@(TCRealValue(42)));
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(whiteView).offset(TCRealValue(12));
        make.top.equalTo(titleLabel.mas_bottom);
        make.right.equalTo(whiteView).offset(-TCRealValue(12));
        make.height.equalTo(@0.5);
    }];
    
    [_applyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lineView);
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.height.equalTo(@(TCRealValue(30)));
    }];
    
    [_applyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_applyBtn).offset(TCRealValue(15));
        make.top.equalTo(_applyBtn).offset((TCRealValue(30)-TCRealValue(15))/2);
        make.width.height.equalTo(@(TCRealValue(15)));
    }];
    
    [applyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_applyImageView.mas_right).offset(TCRealValue(10));
        make.top.right.bottom.equalTo(_applyBtn);
    }];
    
    [_masterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.right.equalTo(_applyBtn);
        make.top.equalTo(_applyBtn.mas_bottom);
    }];
    
    [_masterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_masterBtn).offset(TCRealValue(15));
        make.top.equalTo(_masterBtn).offset((TCRealValue(30)-TCRealValue(15))/2);
        make.width.height.equalTo(@(TCRealValue(15)));
    }];
    
    [masterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_masterImageView.mas_right).offset(TCRealValue(10));
        make.top.right.bottom.equalTo(_masterBtn);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(whiteView).offset(TCRealValue(25));
        make.top.equalTo(_masterBtn.mas_bottom).offset(TCRealValue(20));
        make.width.equalTo(@(TCRealValue(125)));
        make.height.equalTo(@(TCRealValue(31)));
    }];
    
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(whiteView).offset(-TCRealValue(25));
        make.width.top.height.equalTo(cancelBtn);
    }];
    
}

- (void)applyBtnClick {
    _applyBtn.selected = !_applyBtn.selected;
    if (_applyBtn.selected) {
        _masterBtn.selected = NO;
        _applyImageView.image = [UIImage imageNamed:@"selected"];
        _masterImageView.image = [UIImage imageNamed:@"unSelected"];
    }else {
        _applyImageView.image = [UIImage imageNamed:@"unSelected"];
        _masterImageView.image = [UIImage imageNamed:@"unSelected"];
    }
}

- (void)masterBtnClick {
    _masterBtn.selected = !_masterBtn.selected;
    if (_masterBtn.selected) {
        _applyBtn.selected = NO;
        _applyImageView.image = [UIImage imageNamed:@"unSelected"];
        _masterImageView.image = [UIImage imageNamed:@"selected"];
    }else {
        _applyImageView.image = [UIImage imageNamed:@"unSelected"];
        _masterImageView.image = [UIImage imageNamed:@"unSelected"];
    }
}

- (void)cancelOrder {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)confirmOrder {
    
    if (_applyBtn.selected || _masterBtn.selected) {
        if (self.confirmBlock) {
            if (_applyBtn.selected) {
                self.confirmBlock(@"0");
            }else {
                self.confirmBlock(@"1");
            }
            
        }
    }else {
        [MBProgressHUD showHUDWithMessage:@"请选择取消原因"];
    }
    
}

@end
