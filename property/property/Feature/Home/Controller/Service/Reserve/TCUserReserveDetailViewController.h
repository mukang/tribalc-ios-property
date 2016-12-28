//
//  TCUserReserveDetailViewController.h
//  individual
//
//  Created by WYH on 16/12/4.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "TCOrderDetailAlertView.h"


@interface TCUserReserveDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SDWebImageManagerDelegate, TCOrderDetailAlertViewDelegate>


- (instancetype)initWithReservationId:(NSString *)reservationId;

@end
