//
//  TCAddVisitorDeviceViewCell.m
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCAddVisitorDeviceViewCell.h"

@interface TCAddVisitorDeviceViewCell ()

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *deviceLabel;

@end

@implementation TCAddVisitorDeviceViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"选择门锁";
    titleLabel.textColor = TCRGBColor(42, 42, 42);
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *deviceLabel = [[UILabel alloc] init];
    deviceLabel.textColor = TCRGBColor(186, 186, 186);
    deviceLabel.textAlignment = NSTextAlignmentCenter;
    deviceLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    deviceLabel.layer.cornerRadius = 2.5;
    deviceLabel.layer.borderWidth = 0.5;
    deviceLabel.layer.borderColor = TCRGBColor(186, 186, 186).CGColor;
    deviceLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:deviceLabel];
    self.deviceLabel = deviceLabel;
    deviceLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapDeviceLabel:)];
    [deviceLabel addGestureRecognizer:tap];
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.contentView).offset(20);
        make.centerY.equalTo(weakSelf.contentView);
    }];
    [self.deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(TCRealValue(222.5), 24));
        make.leading.equalTo(weakSelf.contentView).offset(95);
        make.centerY.equalTo(weakSelf.contentView);
    }];
}

- (void)setLockName:(NSString *)lockName {
    _lockName = lockName;
    
    self.deviceLabel.text = lockName;
}

- (void)handleTapDeviceLabel:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapDeviceLabelInAddVisitorDeviceViewCell:)]) {
        [self.delegate didTapDeviceLabelInAddVisitorDeviceViewCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
