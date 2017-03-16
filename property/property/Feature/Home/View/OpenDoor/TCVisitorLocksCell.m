//
//  TCVisitorLocksCell.m
//  individual
//
//  Created by 王帅锋 on 17/3/10.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCVisitorLocksCell.h"
#import <Masonry.h>

@interface TCVisitorLocksCell ()

@property (strong, nonatomic) UIImageView *leftImageView;

@property (strong, nonatomic) UILabel *textL;

@property (strong, nonatomic) UIButton *rightBtn;

@end

@implementation TCVisitorLocksCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    [self.contentView addSubview:self.rightBtn];
    self.textLabel.font = [UIFont systemFontOfSize:14];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@24);
        make.height.equalTo(@28);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.imageView.frame;
    frame.origin.x += 10;
    self.imageView.frame = frame;
}

- (UIButton *)rightBtn {
    if (_rightBtn == nil) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"deleteVisitor"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (void)delete {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(deleteEquip:)]) {
            [self.delegate deleteEquip:self];
        }
    }
}

//- (UIImageView *)rightImageView {
//    if (_rightImageView == nil) {
//        _rightImageView = [[UIImageView alloc] init];
//        _rightImageView.image = [UIImage imageNamed:@"deleteVisitor"];
//    }
//    return _rightImageView;
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
