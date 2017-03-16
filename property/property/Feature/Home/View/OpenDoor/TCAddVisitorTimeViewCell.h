//
//  TCAddVisitorTimeViewCell.h
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCAddVisitorTimeViewCellDelegate;
@interface TCAddVisitorTimeViewCell : UITableViewCell

@property (weak, nonatomic) NSString *endTime;
@property (weak, nonatomic) id<TCAddVisitorTimeViewCellDelegate> delegate;

@end

@protocol TCAddVisitorTimeViewCellDelegate <NSObject>

@optional
- (void)didTapEndLabelInAddVisitorTimeViewCell:(TCAddVisitorTimeViewCell *)cell;

@end
