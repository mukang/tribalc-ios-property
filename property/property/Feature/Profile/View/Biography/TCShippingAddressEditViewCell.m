//
//  TCShippingAddressEditViewCell.m
//  individual
//
//  Created by 穆康 on 2016/11/2.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShippingAddressEditViewCell.h"

@interface TCShippingAddressEditViewCell ()

@property (weak, nonatomic) IBOutlet UIView *addressView;

@end

@implementation TCShippingAddressEditViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(handleTapAddressView:)];
    [self.addressView addGestureRecognizer:tapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)handleTapAddressView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapAddressViewInShippingAddressEditViewCell:)]) {
        [self.delegate didTapAddressViewInShippingAddressEditViewCell:self];
    }
}

@end
