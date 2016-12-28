//
//  TCShoppingCartListTableViewCell.h
//  individual
//
//  Created by WYH on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCShoppingCartSelectButton.h"
#import "TCModelImport.h"
#import "TCComputeView.h"
#import "UIImageView+WebCache.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>



@class TCShoppingCartListTableViewCell;
@protocol TCShoppingCartListTableViewCellDelegate <NSObject>

- (void)shoppingCartCell:(TCShoppingCartListTableViewCell *)cell didTouchSelectButtonWithIndexPath:(NSIndexPath *)indexPath;

- (void)shoppingCartCell:(TCShoppingCartListTableViewCell *)cell didSelectSelectStandardWithCartItem:(TCCartItem *)cartItem;

- (void)shoppingCartCell:(TCShoppingCartListTableViewCell *)cell AddOrSubAmountWithCartItem:(TCCartItem *)cartItem;

@end



@interface TCShoppingCartListTableViewCell : MGSwipeTableCell <SDWebImageManagerDelegate, MGSwipeTableCellDelegate>

+ (instancetype)cellForTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)editCellForTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath;

- (void)setEditCartItem:(TCCartItem *)cartItem;

@property (weak, nonatomic) TCShoppingCartSelectButton *selectBtn;
@property (weak, nonatomic) UIImageView *leftImageView;
@property (weak, nonatomic) UILabel *titleLab;
@property (weak, nonatomic) UILabel *primaryStandardLab;
@property (weak, nonatomic) UIButton *secondaryStandardBtn;
@property (weak, nonatomic) UILabel *amountLab;
@property (weak, nonatomic) UILabel *priceLab;

@property (strong, nonatomic) TCCartItem *cartItem;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (nonatomic, weak) id<TCShoppingCartListTableViewCellDelegate> shopCartDelegate;

@end
