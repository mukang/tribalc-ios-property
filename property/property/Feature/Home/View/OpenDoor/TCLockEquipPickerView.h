//
//  TCLockEquipPickerView.h
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLockEquip.h"

@protocol TCLockEquipPickerViewDelegate;
@interface TCLockEquipPickerView : UIView


@property (weak, nonatomic) id<TCLockEquipPickerViewDelegate> delegate;

@property (copy, nonatomic) NSArray *lockEquips;
- (instancetype)initWithController:(UIViewController *)controller;
- (void)show;

@end

@protocol TCLockEquipPickerViewDelegate <NSObject>

@optional
- (void)equipPickerView:(TCLockEquipPickerView *)view didClickConfirmButtonWithEquip:(TCLockEquip *)equip;

@end
