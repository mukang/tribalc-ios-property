//
//  TCLockQRCodeTitleView.m
//  individual
//
//  Created by 穆康 on 2017/3/10.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLockQRCodeTitleView.h"

@interface TCLockQRCodeTitleView ()

@property (weak, nonatomic) UIImageView *imageView;

@end

@implementation TCLockQRCodeTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 7.5;
        self.layer.masksToBounds = YES;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_QR_code_title"]];
    [self addSubview:imageView];
    
    UILabel *visitorLabel = [[UILabel alloc] init];
    visitorLabel.textColor = TCBlackColor;
    visitorLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:visitorLabel];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    phoneLabel.textColor = TCBlackColor;
    phoneLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:phoneLabel];
    
    self.imageView = imageView;
    self.visitorLabel = visitorLabel;
    self.phoneLabel = phoneLabel;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(TCRealValue(33), TCRealValue(38)));
        make.leading.equalTo(weakSelf).offset(TCRealValue(60));
        make.centerY.equalTo(weakSelf);
    }];

    [self.visitorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.top.equalTo(weakSelf).offset(TCRealValue(25));
        make.leading.equalTo(weakSelf.imageView.mas_trailing).offset(TCRealValue(20));
        make.trailing.equalTo(weakSelf.mas_trailing).offset(-10);
    }];
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.height.equalTo(weakSelf.visitorLabel);
        make.top.equalTo(weakSelf.visitorLabel.mas_bottom).offset(TCRealValue(8));
    }];
}

@end
