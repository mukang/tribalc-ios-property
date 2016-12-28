//
//  TCShoppingCartViewController.h
//  individual
//
//  Created by WYH on 16/11/5.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCComponent.h"
#import "TCGetNavigationItem.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import "TCBuluoApi.h"
#import "TCImageURLSynthesizer.h"
#import "TCShoppingCartWrapper.h"
#import "TCPlaceOrderViewController.h"
#import "TCSelectStandardView.h"
#import "TCShoppingCartListTableViewCell.h"


@interface TCShoppingCartViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, TCShoppingCartListTableViewCellDelegate, TCSelectStandardViewDelegate>


@end
