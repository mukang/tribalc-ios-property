//
//  TCBioEditBirthdateViewCell.m
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBioEditBirthdateViewCell.h"

@interface TCBioEditBirthdateViewCell ()

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIView *containerView;

@end

@implementation TCBioEditBirthdateViewCell

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
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"出生日期";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = TCBlackColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIView *containerView = [[UIView alloc] init];
    [self.contentView addSubview:containerView];
    self.containerView = containerView;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.userInteractionEnabled = NO;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.textColor = TCBlackColor;
    textField.font = [UIFont systemFontOfSize:14];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请选择出生日期"
                                                                      attributes:@{
                                                                                   NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                                   NSForegroundColorAttributeName: TCGrayColor
                                                                                   }];
    textField.returnKeyType = UIReturnKeyDone;
    [containerView addSubview:textField];
    self.textField = textField;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(20);
        make.top.bottom.equalTo(weakSelf.contentView);
        make.width.mas_equalTo(70);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(108);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-20);
        make.top.bottom.equalTo(weakSelf.contentView);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.containerView);
    }];
}

@end
