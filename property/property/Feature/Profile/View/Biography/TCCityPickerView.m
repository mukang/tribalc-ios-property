//
//  TCCityPickerView.m
//  individual
//
//  Created by 穆康 on 2016/11/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCityPickerView.h"

NSString *const TCCityPickierViewProvinceKey = @"TCCityPickierViewProvinceKey";
NSString *const TCCityPickierViewCityKey = @"TCCityPickierViewCityKey";
NSString *const TCCityPickierViewCountryKey = @"TCCityPickierViewCountryKey";

@interface TCCityPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (copy, nonatomic) NSArray *provinceArray;
@property (copy, nonatomic) NSArray *cityArray;
@property (copy, nonatomic) NSArray *countryArray;

@end

@implementation TCCityPickerView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self loadData];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    } else if (component == 1) {
        return self.cityArray.count;
    } else {
        return self.countryArray.count;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    if (component == 0) {
        NSDictionary *provinceDict = [self.provinceArray objectAtIndex:row];
        title = [provinceDict objectForKey:@"n"];
    } else if (component == 1) {
        NSDictionary *cityDict = [self.cityArray objectAtIndex:row];
        title = [cityDict objectForKey:@"n"];
    } else {
        NSDictionary *countryDict = [self.countryArray objectAtIndex:row];
        title = [countryDict objectForKey:@"n"];
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{
                                                                         NSFontAttributeName : [UIFont systemFontOfSize:14]
                                                                         }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView selectedRowInComponent:0];
        
        NSDictionary *provinceDict = [self.provinceArray objectAtIndex:row];
        self.cityArray = [provinceDict objectForKey:@"l"];
        [pickerView reloadComponent:1];
        
        NSDictionary *cityDict = [self.cityArray firstObject];
        self.countryArray = [cityDict objectForKey:@"l"];
        [pickerView reloadComponent:2];
    } else if (component == 1) {
        [pickerView selectedRowInComponent:1];
        
        NSDictionary *cityDict = [self.cityArray objectAtIndex:row];
        self.countryArray = [cityDict objectForKey:@"l"];
        [pickerView reloadComponent:2];
    } else {
        [pickerView selectedRowInComponent:2];
    }
}

#pragma mark - Actions

- (IBAction)handleClickConfirmButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cityPickerView:didClickConfirmButtonWithCityInfo:)]) {
        NSDictionary *cityInfo = [self getCurrentSelectedInfo];
        [self.delegate cityPickerView:self didClickConfirmButtonWithCityInfo:cityInfo];
    }
}

- (IBAction)handleClickCancelButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickCancelButtonInCityPickerView:)]) {
        [self.delegate didClickCancelButtonInCityPickerView:self];
    }
}

#pragma mark - Get Current Info

- (NSDictionary *)getCurrentSelectedInfo {
    NSInteger provinceIndex = [self.pickerView selectedRowInComponent:0];
    NSInteger cityIndex = [self.pickerView selectedRowInComponent:1];
    NSInteger countryIndex = [self.pickerView selectedRowInComponent:2];
    
    NSString *province = self.provinceArray[provinceIndex][@"n"];
    NSString *city = self.cityArray.count != 0 ? self.cityArray[cityIndex][@"n"] : @"";
    NSString *country = self.countryArray.count != 0 ? self.countryArray[countryIndex][@"n"] : @"";
    
    return @{
             TCCityPickierViewProvinceKey : province,
             TCCityPickierViewCityKey     : city,
             TCCityPickierViewCountryKey  : country
             };
}

#pragma mark - Load Data

- (void)loadData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"citylist" ofType:@"data"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *dictArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.provinceArray = dictArray;
    NSDictionary *provinceDict = [self.provinceArray firstObject];
    self.cityArray = provinceDict[@"l"];
    NSDictionary *cityDict = [self.cityArray firstObject];
    self.countryArray = cityDict[@"l"];
}

@end
