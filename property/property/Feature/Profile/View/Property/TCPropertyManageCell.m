//
//  TCPropertyManageCell.m
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPropertyManageCell.h"

@interface TCPropertyManageCell ()
@property (weak, nonatomic) IBOutlet UILabel *communityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *applyPersonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *appiontTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *masterPersonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *doorTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *masterInfoConstraintHeight;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIImageView *finishedImage;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@end


@implementation TCPropertyManageCell

- (void)setPropertyManage:(TCPropertyManage *)propertyManage {
    if (propertyManage != _propertyManage) {
        _propertyManage = propertyManage;
        
        NSTimeInterval appointTime = propertyManage.appointTime/1000;
        NSDate *appointDate = [NSDate dateWithTimeIntervalSince1970:appointTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSTimeInterval doorTime = propertyManage.doorTime/1000;
        NSDate *doorDate = [NSDate dateWithTimeIntervalSince1970:doorTime];
        _orderNumLabel.text = propertyManage.propertyNum ? [NSString stringWithFormat:@"订单号:%@",propertyManage.propertyNum] : @"";
        _communityNameLabel.text = propertyManage.communityName ? propertyManage.communityName : @"";
        _companyNameLabel.text =  propertyManage.companyName ? propertyManage.companyName : @"";
        _applyPersonNameLabel.text = propertyManage.applyPersonName ? propertyManage.applyPersonName : @"";
        _floorLabel.text = propertyManage.floor ? [NSString stringWithFormat:@"%@层",propertyManage.floor] : @"";
        _appiontTimeLabel.text = [formatter stringFromDate:appointDate];
        _phoneLabel.text = propertyManage.phone;
        _masterPersonNameLabel.text = propertyManage.masterPersonName ? propertyManage.masterPersonName : @"";
        _doorTimeLabel.text = [formatter stringFromDate:doorDate];
        _masterView.hidden = [propertyManage.status isEqualToString:@"ORDER_ACCEPT"];
        
        if (propertyManage.fixProject) {
            if ([propertyManage.fixProject isEqualToString:@"PIPE_FIX"]) {
                _projectTypeLabel.text = @"管件维修";
            }else if ([propertyManage.fixProject isEqualToString:@"PUBLIC_LIGHTING"]) {
                _projectTypeLabel.text = @"公共照明";
            }else if ([propertyManage.fixProject isEqualToString:@"WATER_PIPE_FIX"]) {
                _projectTypeLabel.text = @"水管维修";
            }else if ([propertyManage.fixProject isEqualToString:@"ELECTRICAL_FIX"]) {
                _projectTypeLabel.text = @"电器维修";
            }else {
                _projectTypeLabel.text = @"其他";
            }
        }else {
            _projectTypeLabel.text = @"";
        }
        
        
        if (propertyManage.status) {
            if ([propertyManage.status isEqualToString:@"ORDER_ACCEPT"]) {
                [_statusBtn setTitle:@"待接单" forState:UIControlStateNormal];
                _finishedImage.hidden = YES;
                _masterView.hidden = YES;
            }else if ([propertyManage.status isEqualToString:@"TASK_CONFIRM"]) {
                [_statusBtn setTitle:@"已接单" forState:UIControlStateNormal];
                _finishedImage.hidden = YES;
                _masterView.hidden = NO;
            }else if ([propertyManage.status isEqualToString:@"TO_PAYING"]) {
                [_statusBtn setTitle:@"待付款" forState:UIControlStateNormal];
                _finishedImage.hidden = YES;
                _masterView.hidden = NO;
            }else if ([propertyManage.status isEqualToString:@"PAY_ED"]) {
                [_statusBtn setTitle:@"已完成" forState:UIControlStateNormal];
                _finishedImage.hidden= NO;
                _masterView.hidden = NO;
            }else if ([propertyManage.status isEqualToString:@"TO_FIX"]) {
                [_statusBtn setTitle:@"待维修" forState:UIControlStateNormal];
                _finishedImage.hidden= YES;
                _masterView.hidden = NO;
            }else if ([propertyManage.status isEqualToString:@"CANCEL"]) {
                [_statusBtn setTitle:@"已取消" forState:UIControlStateNormal];
                _finishedImage.hidden= YES;
                _masterView.hidden = YES;
            }else {
                [_statusBtn setTitle:@"" forState:UIControlStateNormal];
                _finishedImage.hidden = YES;
                _masterView.hidden = YES;
            }
        }else {
            [_statusBtn setTitle:@"" forState:UIControlStateNormal];
            _finishedImage.hidden = YES;
            _masterView.hidden = YES;
        }
        
        if (propertyManage.totalFee) {
            _moneyLabel.hidden = NO;
            NSString *money = [NSString stringWithFormat:@"%.2f",propertyManage.totalFee];
            if (money) {
                NSString *s = [NSString stringWithFormat:@"维修金额 ¥%.2f",propertyManage.totalFee];
                NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:s];
                
                [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255 green:19/255.0 blue:19/255.0 alpha:1.0] range:NSMakeRange(5, s.length-5)];
                _moneyLabel.attributedText = attStr;
            }else {
                _moneyLabel.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
            }
        }else {
            _moneyLabel.hidden = YES;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
