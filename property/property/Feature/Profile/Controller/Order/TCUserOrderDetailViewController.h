//
//  TCUserOrderDetailViewController.h
//  individual
//
//  Created by WYH on 16/11/26.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCGetNavigationItem.h"
#import "TCOrderAddressView.h"
#import "TCUserOrderTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "TCClientConfig.h"
#import "TCModelImport.h"
#import "TCImageURLSynthesizer.h"
#import "TCOrderDetailAlertView.h"
#import "TCUserOrderTabBarController.h"
#import "TCPlaceOrderViewController.h"
#import "TCShoppingCartViewController.h"
#import "TCBuluoApi.h"
#import "TCPaymentView.h"



@interface TCUserOrderDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SDWebImageManagerDelegate, TCOrderDetailAlertViewDelegate, TCPaymentViewDelegate>



//- (instancetype)initWithOrder:(TCOrder *)order;

@end
