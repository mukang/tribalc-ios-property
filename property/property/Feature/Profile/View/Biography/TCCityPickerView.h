//
//  TCCityPickerView.h
//  individual
//
//  Created by 穆康 on 2016/11/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCCityPickerView;

extern NSString *const TCCityPickierViewProvinceKey;
extern NSString *const TCCityPickierViewCityKey;
extern NSString *const TCCityPickierViewCountryKey;

@protocol TCCityPickerViewDelegate <NSObject>

@optional
- (void)cityPickerView:(TCCityPickerView *)view didClickConfirmButtonWithCityInfo:(NSDictionary *)cityInfo;
- (void)didClickCancelButtonInCityPickerView:(TCCityPickerView *)view;

@end

@interface TCCityPickerView : UIView

@property (weak, nonatomic) id<TCCityPickerViewDelegate> delegate;

@end
