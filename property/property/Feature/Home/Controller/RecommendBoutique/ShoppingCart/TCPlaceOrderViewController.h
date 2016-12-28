//
//  TCPlaceOrderViewController.h
//  individual
//
//  Created by WYH on 16/12/11.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface TCPlaceOrderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SDWebImageManagerDelegate, UITextFieldDelegate>

- (instancetype)initWithListShoppingCartArr:(NSArray *)listShoppingCart;



@end
