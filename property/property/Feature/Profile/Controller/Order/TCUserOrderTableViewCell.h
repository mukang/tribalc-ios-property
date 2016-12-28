//
//  TCUserOrderTableViewCell.h
//  individual
//
//  Created by WYH on 16/11/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCComponent.h"
//#import "TCOrderItem.h"
#import "UIImageView+WebCache.h"

@interface TCUserOrderTableViewCell : UITableViewCell <SDWebImageManagerDelegate>


+ (instancetype)cellWithTableView:(UITableView *)tableView;

//- (void)setOrderListOrderItem:(TCOrderItem *)orderItem ;
//
//- (void)setOrderDetailOrderItem:(TCOrderItem *)orderItem;
//
//@property (nonatomic, strong) TCOrderItem *orderItem;

@property (nonatomic) UIView *backView;

@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) UIImageView *leftImageView;
@property (nonatomic, weak) UILabel *priceLab;
@property (nonatomic, weak) UILabel *standardLab;
@property (nonatomic, weak) UILabel *numberLab;

@end
