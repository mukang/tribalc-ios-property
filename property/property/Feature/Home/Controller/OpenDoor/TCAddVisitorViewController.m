//
//  TCAddVisitorViewController.m
//  individual
//
//  Created by 穆康 on 2017/3/13.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCAddVisitorViewController.h"
#import "TCLockQRCodeViewController.h"

#import <TCCommonLibs/TCCommonButton.h>
#import "TCCommonInputViewCell.h"
#import "TCAddVisitorTimeViewCell.h"
#import "TCAddVisitorDeviceViewCell.h"

#import <TCCommonLibs/TCDatePickerView.h>
#import "TCLockEquipPickerView.h"

#import "TCBuluoApi.h"

@interface TCAddVisitorViewController ()
<UITableViewDataSource,
UITableViewDelegate,
TCCommonInputViewCellDelegate,
TCAddVisitorTimeViewCellDelegate,
TCAddVisitorDeviceViewCellDelegate,
TCDatePickerViewDelegate,
TCLockEquipPickerViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) TCLockKey *lockKey;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation TCAddVisitorViewController {
    __weak TCAddVisitorViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    weakSelf = self;
    self.navigationItem.title = @"添加访客";
    
    [self setupSubviews];
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - Private Methods

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = TCBackgroundColor;
    tableView.separatorColor = TCSeparatorLineColor;
    tableView.dataSource = self;
    tableView.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"TCCommonInputViewCell" bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forCellReuseIdentifier:@"TCCommonInputViewCell"];
    [tableView registerClass:[TCAddVisitorTimeViewCell class] forCellReuseIdentifier:@"TCAddVisitorTimeViewCell"];
    [tableView registerClass:[TCAddVisitorDeviceViewCell class] forCellReuseIdentifier:@"TCAddVisitorDeviceViewCell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(weakSelf.view);
    }];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth, 100)];
    footerView.backgroundColor = TCBackgroundColor;
    TCCommonButton *generateButton = [TCCommonButton buttonWithTitle:@"生成二维码" color:TCCommonButtonColorBlue target:self action:@selector(handleClickGenerateButton:)];
    generateButton.y = 37;
    generateButton.centerX = TCScreenWidth * 0.5;
    [footerView addSubview:generateButton];
    tableView.tableFooterView = footerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *currentCell;
    switch (indexPath.row) {
        case 0:
        case 1:
        {
            TCCommonInputViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCommonInputViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            if (indexPath.row == 0) {
                cell.title = @"姓名";
                cell.placeholder = @"请填写姓名";
                cell.content = self.lockKey.name;
                cell.keyboardType = UIKeyboardTypeDefault;
            } else {
                cell.title = @"电话";
                cell.placeholder = @"请填写电话";
                cell.content = self.lockKey.phone;
                cell.keyboardType = UIKeyboardTypeNumberPad;
            }
            currentCell = cell;
        }
            break;
        case 2:
        {
            TCAddVisitorTimeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCAddVisitorTimeViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            if (self.lockKey.endTime) {
                cell.endTime = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.lockKey.endTime / 1000]];
            } else {
                cell.endTime = @"请选择";
            }
            currentCell = cell;
        }
            break;
        case 3:
        {
            TCAddVisitorDeviceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCAddVisitorDeviceViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.lockName = self.lockKey.equipName ?: @"请选择";
            currentCell = cell;
        }
            break;
            
        default:
            break;
    }
    return currentCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView endEditing:YES];
}

#pragma mark - TCCommonInputViewCellDelegate

- (void)commonInputViewCell:(TCCommonInputViewCell *)cell textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        self.lockKey.name = textField.text;
    } else if (indexPath.row == 1) {
        self.lockKey.phone = textField.text;
    }
}

- (BOOL)commonInputViewCell:(TCCommonInputViewCell *)cell textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - TCAddVisitorTimeViewCellDelegate

- (void)didTapEndLabelInAddVisitorTimeViewCell:(TCAddVisitorTimeViewCell *)cell {
    TCDatePickerView *datePickerView = [[TCDatePickerView alloc] initWithController:self];
    datePickerView.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePickerView.datePicker.date = self.lockKey.endTime ? [NSDate dateWithTimeIntervalSince1970:self.lockKey.endTime/1000] : [NSDate date];
    datePickerView.datePicker.minimumDate = [NSDate date];
    datePickerView.datePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:(60 * 60 * 24)];
    datePickerView.delegate = self;
    [datePickerView show];
    
    [self.tableView endEditing:YES];
}

#pragma mark - TCAddVisitorDeviceViewCellDelegate

- (void)didTapDeviceLabelInAddVisitorDeviceViewCell:(TCAddVisitorDeviceViewCell *)cell {
    [self.tableView endEditing:YES];
    
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] fetchMyLockListResult:^(NSArray *lockList, NSError *error) {
        if (lockList) {
            if (lockList.count) {
                [MBProgressHUD hideHUD:YES];
                [weakSelf handleShowLockEquipPickerViewWithLockList:lockList];
            } else {
                [MBProgressHUD showHUDWithMessage:@"您当前还没有门锁设备"];
            }
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取设备数据失败，%@", reason]];
        }
    }];
}

#pragma mark - TCDatePickerViewDelegate

- (void)didClickConfirmButtonInDatePickerView:(TCDatePickerView *)view {
    NSTimeInterval timestamp = [view.datePicker.date timeIntervalSince1970];
    self.lockKey.endTime = (NSInteger)(timestamp * 1000);
    [self.tableView reloadData];
}

#pragma mark - TCLockEquipPickerViewDelegate

- (void)equipPickerView:(TCLockEquipPickerView *)view didClickConfirmButtonWithEquip:(TCLockEquip *)equip {
    self.lockKey.equipName = equip.name;
    self.lockKey.equipId = equip.ID;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)handleClickGenerateButton:(TCCommonButton *)sender {
    [self.tableView endEditing:YES];
    
    if (self.lockKey.name.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请填写访客姓名"];
        return;
    }
    if (self.lockKey.phone.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请填写访客电话"];
        return;
    }
    if (self.lockKey.endTime == 0) {
        [MBProgressHUD showHUDWithMessage:@"请选择结束时间"];
        return;
    }
    if (self.lockKey.equipName.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请选择门锁"];
        return;
    }
    TCUserInfo *userInfo = [[TCBuluoApi api] currentUserSession].userInfo;
    if ([self.lockKey.phone isEqualToString:userInfo.phone]) {
        [MBProgressHUD showHUDWithMessage:@"不能添加自己的手机号"];
        return;
    }
    
    TCVisitorInfo *info = [[TCVisitorInfo alloc] init];
    info.equipId = self.lockKey.equipId;
    info.phone = self.lockKey.phone;
    info.name = self.lockKey.name;
    info.beginTime = [[NSDate date] timeIntervalSince1970] * 1000;
    info.endTime = self.lockKey.endTime;
    [[TCBuluoApi api] fetchLockKeyWithVisitorInfo:info result:^(TCLockKey *lockKey, NSError *error) {
        if (lockKey) {
            if (weakSelf.addVisitorCompletion) {
                weakSelf.addVisitorCompletion();
            }
            TCLockQRCodeViewController *vc = [[TCLockQRCodeViewController alloc] initWithLockQRCodeType:TCLockQRCodeTypeVisitor];
            vc.lockKey = lockKey;
            vc.fromController = weakSelf.fromController;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"生成二维码失败，%@", reason]];
        }
    }];
}

- (void)handleShowLockEquipPickerViewWithLockList:(NSArray *)lockList {
    TCLockEquipPickerView *equipPickerView = [[TCLockEquipPickerView alloc] initWithController:self];
    equipPickerView.lockEquips = lockList;
    equipPickerView.delegate = self;
    [equipPickerView show];
}

#pragma mark - Override Methods

- (TCLockKey *)lockKey {
    if (_lockKey == nil) {
        _lockKey = [[TCLockKey alloc] init];
    }
    return _lockKey;
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _dateFormatter.dateFormat = @"MM月dd日 HH:mm";
    }
    return _dateFormatter;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
