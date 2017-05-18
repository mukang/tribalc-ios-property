//
//  TCLockEquipViewCell.m
//  individual
//
//  Created by 穆康 on 2017/5/18.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLockEquipViewCell.h"
#import "TCLockEquip.h"

#define NormalImage   [UIImage imageNamed:@"profile_common_address_button_normal"]
#define SelectedImage [UIImage imageNamed:@"profile_common_address_button_selected"]

@interface TCLockEquipViewCell ()

@property (weak, nonatomic) UIImageView *logoImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIImageView *markImageView;

@end

@implementation TCLockEquipViewCell

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapContentView:)];
    [self.contentView addGestureRecognizer:tap];
    
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = [UIImage imageNamed:@"locks"];
    [self.contentView addSubview:logoImageView];
    self.logoImageView = logoImageView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = TCBlackColor;
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIImageView *markImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:markImageView];
    self.markImageView = markImageView;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 18.5));
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(20);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(21);
        make.left.equalTo(weakSelf.logoImageView.mas_right).with.offset(11);
        make.right.equalTo(weakSelf.markImageView.mas_left).with.offset(-11);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(17, 17));
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-20);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
}

- (void)handleTapContentView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(lockEquipViewCell:didSelectedLockEquip:)]) {
        [self.delegate lockEquipViewCell:self didSelectedLockEquip:self.lockEquip];
    }
}

- (void)setLockEquip:(TCLockEquip *)lockEquip {
    _lockEquip = lockEquip;
    
    self.titleLabel.text = lockEquip.name;
    self.markImageView.image = lockEquip.isMarked ? SelectedImage : NormalImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
