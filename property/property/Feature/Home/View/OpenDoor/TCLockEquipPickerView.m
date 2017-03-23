//
//  TCLockEquipPickerView.m
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLockEquipPickerView.h"

static CGFloat const duration = 0.25;

@interface TCLockEquipPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) UIView *containerView;
@property (weak, nonatomic) UIPickerView *pickerView;

@end

@implementation TCLockEquipPickerView {
    __weak TCLockEquipPickerView *weakSelf;
    __weak UIViewController *sourceController;
}

- (instancetype)initWithController:(UIViewController *)controller {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        weakSelf = self;
        sourceController = controller;
        [self initPrivate];
    }
    return self;
}

- (void)show {
    if (!sourceController) return;
    
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    [superView addSubview:self];
    [superView bringSubviewToFront:self];
    
    [UIView animateWithDuration:duration animations:^{
        weakSelf.backgroundColor = TCARGBColor(0, 0, 0, 0.62);
        weakSelf.containerView.y = TCScreenHeight - weakSelf.containerView.height;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:duration animations:^{
        weakSelf.backgroundColor = TCARGBColor(0, 0, 0, 0);
        weakSelf.containerView.y = TCScreenHeight;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - Private Methods

- (void)initPrivate {
    self.backgroundColor = TCARGBColor(0, 0, 0, 0);
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.backgroundColor = TCARGBColor(0, 0, 0, 0);
    [self addSubview:backgroundView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBgView:)];
    [backgroundView addGestureRecognizer:tapGesture];
    
    CGFloat containerViewH = 256;
    CGFloat buttonW = 60;
    CGFloat buttonH = 40;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, TCScreenHeight, TCScreenWidth, containerViewH)];
    containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:containerView];
    self.containerView = containerView;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    NSAttributedString *attTitle = [[NSAttributedString alloc] initWithString:@"取消"
                                                                   attributes:@{
                                                                                NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName: TCRGBColor(81, 199, 209)
                                                                                }];
    [cancelButton setAttributedTitle:attTitle forState:UIControlStateNormal];
    attTitle = [[NSAttributedString alloc] initWithString:@"取消"
                                               attributes:@{
                                                            NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                            NSForegroundColorAttributeName: TCRGBColor(10, 164, 177)
                                                            }];
    [cancelButton setAttributedTitle:attTitle forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(handleClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(20, 0, buttonW, buttonH);
    [containerView addSubview:cancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    attTitle = [[NSAttributedString alloc] initWithString:@"确定"
                                               attributes:@{
                                                            NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                            NSForegroundColorAttributeName: TCRGBColor(81, 199, 209)
                                                            }];
    [confirmButton setAttributedTitle:attTitle forState:UIControlStateNormal];
    attTitle = [[NSAttributedString alloc] initWithString:@"确定"
                                               attributes:@{
                                                            NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                            NSForegroundColorAttributeName: TCRGBColor(10, 164, 177)
                                                            }];
    [confirmButton setAttributedTitle:attTitle forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(handleClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = CGRectMake(containerView.width - 20 - buttonW, 0, buttonW, buttonH);
    [containerView addSubview:confirmButton];
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.backgroundColor = TCBackgroundColor;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.frame = CGRectMake(0, 40, containerView.width, containerView.height - 40);
    [containerView addSubview:pickerView];
    self.pickerView = pickerView;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.lockEquips.count;
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = TCBlackColor;
        label.font = [UIFont systemFontOfSize:16];
        label.adjustsFontSizeToFitWidth = YES;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    }
    TCLockEquip *lockEquip = self.lockEquips[row];
    label.text = lockEquip.name;
    return label;
}

#pragma mark - Actions

- (void)handleClickCancelButton:(UIButton *)sender {
    [self dismiss];
}

- (void)handleClickConfirmButton:(UIButton *)sender {
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    TCLockEquip *lockEquip = self.lockEquips[row];
    if ([self.delegate respondsToSelector:@selector(equipPickerView:didClickConfirmButtonWithEquip:)]) {
        [self.delegate equipPickerView:self didClickConfirmButtonWithEquip:lockEquip];
    }
    
    [self dismiss];
}

- (void)handleTapBgView:(UITapGestureRecognizer *)gesture {
    [self dismiss];
}

@end
