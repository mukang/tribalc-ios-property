//
//  TCShippingAddressViewCell.h
//  individual
//
//  Created by 穆康 on 2016/11/2.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCExtendButton.h"
@class TCUserShippingAddress;
@class TCShippingAddressViewCell;

@protocol TCShippingAddressViewCellDelegate <NSObject>

@optional
- (void)shippingAddressViewCell:(TCShippingAddressViewCell *)cell didClickDefaultAddressButtonWithShippingAddress:(TCUserShippingAddress *)shippingAddress;
- (void)shippingAddressViewCell:(TCShippingAddressViewCell *)cell didClickEditAddressButtonWithShippingAddress:(TCUserShippingAddress *)shippingAddress;
- (void)shippingAddressViewCell:(TCShippingAddressViewCell *)cell didClickDeleteAddressButtonWithShippingAddress:(TCUserShippingAddress *)shippingAddress;

@end

@interface TCShippingAddressViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TCExtendButton *defaultAddressButton;

@property (strong, nonatomic) TCUserShippingAddress *shippingAddress;

@property (weak, nonatomic) id<TCShippingAddressViewCellDelegate> delegate;

@end
