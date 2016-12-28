//
//  TCSelectStandardView.h
//  individual
//
//  Created by WYH on 16/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "TCModelImport.h"

@class TCSelectStandardView;
@protocol TCSelectStandardViewDelegate <NSObject>

- (void)selectStandardView:(TCSelectStandardView *)standardView didSelectConfirmButtonWithNumber:(NSInteger)number NewGoodsId:(NSString *)goodsId ShoppingCartGoodsId:(NSString *)shoppingCartGoodsId;

@end

@interface TCSelectStandardView : UIView <SDWebImageManagerDelegate>

- (instancetype)initWithCartItem:(TCCartItem *)cartItem;

@property (retain, nonatomic) UILabel *numberLab;

@property (retain, nonatomic) UILabel *primaryStandardLab;

@property (retain, nonatomic) UILabel *secondaryStandardLab;

@property (weak, nonatomic) id<TCSelectStandardViewDelegate> delegate;

@end
