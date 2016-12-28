//
//  TCBioEditSelectViewCell.m
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBioEditSelectViewCell.h"
#import <Masonry.h>

@interface TCBioEditSelectViewCell ()

@property (weak, nonatomic) UIImageView *selectedImageView;

@end

@implementation TCBioEditSelectViewCell

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
    titleLabel.text = @"昵称";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = TCRGBColor(154, 154, 154);
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIImageView *selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"biography_edit_selected_icon"]];
    selectedImageView.hidden = YES;
    [self.contentView addSubview:selectedImageView];
    self.selectedImageView = selectedImageView;
}

- (void)setupConstraints {
    __weak typeof(self) weakSelf = self;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(20);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-50);
        make.top.bottom.equalTo(weakSelf.contentView);
    }];
    
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(17.5, 17.5));
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(-20);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        self.titleLabel.textColor = TCRGBColor(81, 199, 209);
        self.selectedImageView.hidden = NO;
    } else {
        self.titleLabel.textColor = TCRGBColor(154, 154, 154);
        self.selectedImageView.hidden = YES;
    }
}

@end
