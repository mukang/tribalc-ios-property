//
//  TCCompanyIntroViewCell.h
//  individual
//
//  Created by 穆康 on 2016/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCCompanyInfo;
@class TCCompanyIntroViewCell;

@protocol TCCompanyIntroViewCellDelegate <NSObject>

@optional
- (void)companyIntroViewCell:(TCCompanyIntroViewCell *)cell didClickUnfoldButtonWithFold:(BOOL)fold;

@end

@interface TCCompanyIntroViewCell : UITableViewCell

/** 是否折叠，默认为折叠状态 */
@property (nonatomic) BOOL fold;
@property (strong, nonatomic) TCCompanyInfo *companyInfo;
@property (weak, nonatomic) id<TCCompanyIntroViewCellDelegate> delegate;

@end
