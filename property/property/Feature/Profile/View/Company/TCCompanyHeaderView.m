//
//  TCCompanyHeaderView.m
//  individual
//
//  Created by 穆康 on 2016/12/9.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyHeaderView.h"
#import "TCCompanyInfo.h"
#import "TCImageURLSynthesizer.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TCCompanyHeaderView ()

@end

@implementation TCCompanyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithFrame:frame];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviewsWithFrame:(CGRect)frame {
    TCImagePlayerView *imagePalyerView = [[TCImagePlayerView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self addSubview:imagePalyerView];
    self.imagePalyerView = imagePalyerView;
    
    UIView *logoBgView = [[UIView alloc] init];
    logoBgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.19];
    logoBgView.layer.cornerRadius = 32;
    logoBgView.layer.masksToBounds = YES;
    [self addSubview:logoBgView];
    self.logoBgView = logoBgView;
    
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.layer.cornerRadius = 29;
    logoImageView.layer.masksToBounds = YES;
    [self addSubview:logoImageView];
    self.logoImageView = logoImageView;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    
    [self.logoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(64);
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.centerY.equalTo(weakSelf.mas_bottom);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(58);
        make.center.equalTo(weakSelf.logoBgView);
    }];
}

- (void)setCompanyInfo:(TCCompanyInfo *)companyInfo {
    _companyInfo = companyInfo;
    
    NSURL *logoURL = [TCImageURLSynthesizer synthesizeImageURLWithPath:companyInfo.logo];
    [self.logoImageView sd_setImageWithURL:logoURL placeholderImage:nil options:SDWebImageRetryFailed];
    
    self.imagePalyerView.pictures = companyInfo.pictures;
    if (companyInfo.pictures.count == 1) {
        self.imagePalyerView.autoPlayEnabled = NO;
    }
}

@end
