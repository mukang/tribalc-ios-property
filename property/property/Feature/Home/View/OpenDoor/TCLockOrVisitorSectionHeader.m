//
//  TCLockOrVisitorSectionHeader.m
//  individual
//
//  Created by 王帅锋 on 17/3/10.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLockOrVisitorSectionHeader.h"
#import <Masonry.h>

@interface TCLockOrVisitorSectionHeader ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIView *lineView;

@end

@implementation TCLockOrVisitorSectionHeader


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setUpViews];
    }
    return self;
}

- (void)setName:(NSString *)name {
    if (_name != name) {
        _name = name;
        self.titleLabel.text = name;
    }
}

- (void)setUpViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.lineView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.width.equalTo(@18);
        make.height.equalTo(@17);
    }];
    CGFloat scale = TCScreenWidth > 375.0 ? 3 : 2;
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(@(1/scale));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(5);
        make.top.right.equalTo(self);
        make.bottom.equalTo(self.lineView.mas_top);
    }];
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"visitorList"];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TCRGBColor(42, 42, 42);
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = @"张小花";
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = TCRGBColor(186, 186, 186);
    }
    return _lineView;
}

@end
