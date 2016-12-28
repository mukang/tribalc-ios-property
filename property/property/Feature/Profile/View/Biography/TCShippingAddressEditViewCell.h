//
//  TCShippingAddressEditViewCell.h
//  individual
//
//  Created by 穆康 on 2016/11/2.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCShippingAddressEditViewCell;

@protocol TCShippingAddressEditViewCellDelegate <NSObject>

@optional
- (void)didTapAddressViewInShippingAddressEditViewCell:(TCShippingAddressEditViewCell *)cell;

@end

@interface TCShippingAddressEditViewCell : UITableViewCell

@property (weak, nonatomic) id<TCShippingAddressEditViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailAddressTextView;

@end
