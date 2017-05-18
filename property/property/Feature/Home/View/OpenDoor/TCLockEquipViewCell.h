//
//  TCLockEquipViewCell.h
//  individual
//
//  Created by 穆康 on 2017/5/18.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TCLockEquip;

@protocol TCLockEquipViewCellDelegate;
@interface TCLockEquipViewCell : UITableViewCell

@property (strong, nonatomic) TCLockEquip *lockEquip;
@property (weak, nonatomic) id<TCLockEquipViewCellDelegate> delegate;

@end

@protocol TCLockEquipViewCellDelegate <NSObject>

@optional
- (void)lockEquipViewCell:(TCLockEquipViewCell *)cell didSelectedLockEquip:(TCLockEquip *)lockEquip;

@end
