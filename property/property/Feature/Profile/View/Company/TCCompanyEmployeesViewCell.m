//
//  TCCompanyEmployeesViewCell.m
//  individual
//
//  Created by 穆康 on 2016/12/12.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyEmployeesViewCell.h"

@implementation TCCompanyEmployeesViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = TCRGBColor(42, 42, 42);
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.textAlignment = NSTextAlignmentLeft;
    subtitleLabel.textColor = TCRGBColor(42, 42, 42);
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:subtitleLabel];
    self.subtitleLabel = subtitleLabel;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(20);
        make.top.and.bottom.equalTo(weakSelf.contentView);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(98);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-20);
        make.top.and.bottom.equalTo(weakSelf.contentView);
    }];
}

@end
