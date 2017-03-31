//
//  TCCompanyIntroViewCell.m
//  individual
//
//  Created by 穆康 on 2016/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyIntroViewCell.h"
#import "TCCompanyInfo.h"
#import <TCCommonLibs/TCExtendButton.h>

@interface TCCompanyIntroViewCell ()

@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *introLabel;
@property (weak, nonatomic) TCExtendButton *foldButton;

@end

@implementation TCCompanyIntroViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = TCBlackColor;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *introLabel = [[UILabel alloc] init];
    introLabel.textColor = TCBlackColor;
    introLabel.font = [UIFont systemFontOfSize:14];
    introLabel.numberOfLines = 0;
    [self.contentView addSubview:introLabel];
    self.introLabel = introLabel;
    
    TCExtendButton *foldButton = [TCExtendButton buttonWithType:UIButtonTypeCustom];
    [foldButton setImage:[UIImage imageNamed:@"company_intro_unfold_button"] forState:UIControlStateNormal];
    [foldButton addTarget:self action:@selector(handleClickUnfoldButton:) forControlEvents:UIControlEventTouchUpInside];
    foldButton.hitTestSlop = UIEdgeInsetsMake(-15, -20, -10, -20);
    [self.contentView addSubview:foldButton];
    self.foldButton = foldButton;
}



- (void)setCompanyInfo:(TCCompanyInfo *)companyInfo {
    _companyInfo = companyInfo;
    
    self.nameLabel.text = companyInfo.companyName;
    
    self.introLabel.text = companyInfo.desc;
    if (companyInfo.desc.length > 80) {
        self.foldButton.hidden = NO;
        if (self.fold) {
            self.introLabel.numberOfLines = 4;
            [self.foldButton setImage:[UIImage imageNamed:@"company_intro_unfold_button"] forState:UIControlStateNormal];
        } else {
            self.introLabel.numberOfLines = 0;
            [self.foldButton setImage:[UIImage imageNamed:@"company_intro_fold_button"] forState:UIControlStateNormal];
        }
    } else {
        self.foldButton.hidden = YES;
        self.introLabel.numberOfLines = 0;
    }
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(weakSelf.contentView);
        make.height.mas_equalTo(19);
        make.top.equalTo(weakSelf.contentView.mas_top).with.offset(38.5);
    }];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(39);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-39);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).with.offset(10);
    }];
    
    [self.foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 8.5));
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.top.equalTo(weakSelf.introLabel.mas_bottom).with.offset(15);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(-10);
    }];
}

- (void)handleClickUnfoldButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(companyIntroViewCell:didClickUnfoldButtonWithFold:)]) {
        [self.delegate companyIntroViewCell:self didClickUnfoldButtonWithFold:self.fold];
    }
}

@end
