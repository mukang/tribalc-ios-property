//
//  TCProfileProcessViewCell.m
//  individual
//
//  Created by 穆康 on 2016/11/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCProfileProcessViewCell.h"
#import "TCUserOrderTabBarController.h"

@interface TCProfileProcessViewCell ()


@end

@implementation TCProfileProcessViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat originSpace = 1, space = 5;
    CGSize imageViewSize, labelSize;
    for (UIButton *button in self.buttons) {
        imageViewSize = button.imageView.size;
        labelSize = button.titleLabel.size;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, labelSize.height + space, -labelSize.width + originSpace);
        button.titleEdgeInsets = UIEdgeInsetsMake(imageViewSize.height + space, -imageViewSize.width + originSpace, 0, 0);
    }
}


#pragma mark - actions


- (IBAction)hadleClickPaymentButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickPaymentButtonInProfileProcessViewCell:)]) {
        [self.delegate didClickPaymentButtonInProfileProcessViewCell:self];
    }
}

- (IBAction)hadleClickReceivingButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickReceivingButtonInProfileProcessViewCell:)]) {
        [self.delegate didClickReceivingButtonInProfileProcessViewCell:self];
    }

}

- (IBAction)hadleClickEvaluationButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickEvaluationButtonInProfileProcessViewCell:)]) {
        [self.delegate didClickEvaluationButtonInProfileProcessViewCell:self];
    }
    
}

- (IBAction)handleClickAfterSaleButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickAfterSaleButtonInProfileProcessViewCell:)]) {
        [self.delegate didClickAfterSaleButtonInProfileProcessViewCell:self];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
