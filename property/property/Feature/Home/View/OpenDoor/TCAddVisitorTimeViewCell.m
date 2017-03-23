//
//  TCAddVisitorTimeViewCell.m
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCAddVisitorTimeViewCell.h"

@interface TCAddVisitorTimeViewCell ()

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *beginLabel;
@property (weak, nonatomic) UILabel *endLabel;
@property (weak, nonatomic) UIView *lineView;

@end

@implementation TCAddVisitorTimeViewCell

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
    titleLabel.text = @"有效期";
    titleLabel.textColor = TCBlackColor;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *beginLabel = [[UILabel alloc] init];
    beginLabel.text = @"当前时间";
    beginLabel.textColor = TCLightGrayColor;
    beginLabel.textAlignment = NSTextAlignmentCenter;
    beginLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    beginLabel.layer.cornerRadius = 2.5;
    beginLabel.layer.borderWidth = 0.5;
    beginLabel.layer.borderColor = TCLightGrayColor.CGColor;
    beginLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:beginLabel];
    self.beginLabel = beginLabel;
    
    UILabel *endLabel = [[UILabel alloc] init];
    endLabel.textColor = TCLightGrayColor;
    endLabel.textAlignment = NSTextAlignmentCenter;
    endLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    endLabel.layer.cornerRadius = 2.5;
    endLabel.layer.borderWidth = 0.5;
    endLabel.layer.borderColor = TCLightGrayColor.CGColor;
    endLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:endLabel];
    self.endLabel = endLabel;
    endLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEndLabel:)];
    [endLabel addGestureRecognizer:tap];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TCLightGrayColor;
    [self.contentView addSubview:lineView];
    self.lineView = lineView;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(weakSelf.contentView).offset(20);
        make.centerY.equalTo(weakSelf.contentView);
    }];
    [self.beginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(TCRealValue(100), 24));
        make.leading.equalTo(weakSelf.contentView).offset(95);
        make.centerY.equalTo(weakSelf.contentView);
    }];
    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(weakSelf.beginLabel);
        make.centerY.equalTo(weakSelf.beginLabel);
        make.leading.equalTo(weakSelf.beginLabel.mas_trailing).offset(23);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2);
        make.centerY.equalTo(weakSelf.beginLabel);
        make.leading.equalTo(weakSelf.beginLabel.mas_trailing).offset(8);
        make.trailing.equalTo(weakSelf.endLabel.mas_leading).offset(-8);
    }];
}

- (void)setEndTime:(NSString *)endTime {
    _endTime = endTime;
    
    self.endLabel.text = endTime;
}

- (void)handleTapEndLabel:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapEndLabelInAddVisitorTimeViewCell:)]) {
        [self.delegate didTapEndLabelInAddVisitorTimeViewCell:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
