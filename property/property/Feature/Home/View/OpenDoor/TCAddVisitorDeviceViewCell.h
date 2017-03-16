//
//  TCAddVisitorDeviceViewCell.h
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCAddVisitorDeviceViewCellDelegate;
@interface TCAddVisitorDeviceViewCell : UITableViewCell

@property (weak, nonatomic) NSString *lockName;
@property (weak, nonatomic) id<TCAddVisitorDeviceViewCellDelegate> delegate;

@end

@protocol TCAddVisitorDeviceViewCellDelegate <NSObject>

@optional
- (void)didTapDeviceLabelInAddVisitorDeviceViewCell:(TCAddVisitorDeviceViewCell *)cell;

@end
