//
//  TCProfileProcessViewCell.h
//  individual
//
//  Created by 穆康 on 2016/11/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCProfileProcessViewCell;

@protocol TCProfileProcessViewCellDelegate <NSObject>

@optional
- (void)didClickPaymentButtonInProfileProcessViewCell:(TCProfileProcessViewCell *)cell;
- (void)didClickReceivingButtonInProfileProcessViewCell:(TCProfileProcessViewCell *)cell;
- (void)didClickEvaluationButtonInProfileProcessViewCell:(TCProfileProcessViewCell *)cell;
- (void)didClickAfterSaleButtonInProfileProcessViewCell:(TCProfileProcessViewCell *)cell;

@end

/**
 购买流程cell
 */
@interface TCProfileProcessViewCell : UITableViewCell

@property (weak, nonatomic) id<TCProfileProcessViewCellDelegate> delegate;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;


@end


