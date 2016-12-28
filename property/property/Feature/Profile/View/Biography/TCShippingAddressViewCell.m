//
//  TCShippingAddressViewCell.m
//  individual
//
//  Created by 穆康 on 2016/11/2.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShippingAddressViewCell.h"
#import "TCUserShippingAddress.h"

@interface TCShippingAddressViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wholeAddressLabel;
@property (weak, nonatomic) IBOutlet TCExtendButton *editButton;
@property (weak, nonatomic) IBOutlet TCExtendButton *deleteButton;

@end

@implementation TCShippingAddressViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupSubviews];
}

- (void)setupSubviews {
    self.defaultAddressButton.hitTestSlop = UIEdgeInsetsMake(-6.5, -20, -6.5, -20);
    self.editButton.hitTestSlop = UIEdgeInsetsMake(-6.5, -20, -6.5, -6);
    self.deleteButton.hitTestSlop = UIEdgeInsetsMake(-6.5, -6, -6.5, -20);
}

- (void)setShippingAddress:(TCUserShippingAddress *)shippingAddress {
    _shippingAddress = shippingAddress;
    
    self.nameLabel.text = shippingAddress.name;
    NSString *province = shippingAddress.province ?: @"";
    NSString *city = shippingAddress.city ?: @"";
    NSString *district = shippingAddress.district ?: @"";
    NSString *address = shippingAddress.address ?: @"";
    self.wholeAddressLabel.text = [NSString stringWithFormat:@"%@%@%@%@", province, city, district, address];
    self.defaultAddressButton.selected = shippingAddress.isDefaultAddress;
}

- (IBAction)handleClickDefaultAddressButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(shippingAddressViewCell:didClickDefaultAddressButtonWithShippingAddress:)]) {
        [self.delegate shippingAddressViewCell:self didClickDefaultAddressButtonWithShippingAddress:self.shippingAddress];
    }
}

- (IBAction)handleClickEditButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(shippingAddressViewCell:didClickEditAddressButtonWithShippingAddress:)]) {
        [self.delegate shippingAddressViewCell:self didClickEditAddressButtonWithShippingAddress:self.shippingAddress];
    }
}

- (IBAction)handleClickDeleteButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(shippingAddressViewCell:didClickDeleteAddressButtonWithShippingAddress:)]) {
        [self.delegate shippingAddressViewCell:self didClickDeleteAddressButtonWithShippingAddress:self.shippingAddress];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
