//
//  TCCompanyApplyNameViewCell.m
//  individual
//
//  Created by 穆康 on 2016/12/13.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyApplyNameViewCell.h"

@implementation TCCompanyApplyNameViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"部门名称";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = TCBlackColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:titleLabel];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = TCBlackColor;
    nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    __weak typeof(self) weakSelf = self;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(20);
        make.top.bottom.equalTo(weakSelf.contentView);
        make.right.mas_equalTo(80);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(100);
        make.top.bottom.equalTo(weakSelf.contentView);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-30);
    }];
}

@end
