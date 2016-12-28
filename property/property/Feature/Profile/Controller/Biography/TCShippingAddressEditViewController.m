//
//  TCShippingAddressEditViewController.m
//  individual
//
//  Created by 穆康 on 2016/11/2.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShippingAddressEditViewController.h"

#import "TCShippingAddressEditViewCell.h"
#import "TCCityPickerView.h"

#import "TCBuluoApi.h"

@interface TCShippingAddressEditViewController ()
<UITableViewDataSource,
UITableViewDelegate,
TCCityPickerViewDelegate,
UITextViewDelegate,
UITextFieldDelegate,
TCShippingAddressEditViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) TCShippingAddressEditViewCell *cell;

@property (weak, nonatomic) UIView *pickerBgView;
@property (weak, nonatomic) TCCityPickerView *cityPickerView;

@end

@implementation TCShippingAddressEditViewController {
    __weak TCShippingAddressEditViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    weakSelf = self;
    [self setupNavBar];
    [self setupSubviews];
}

- (void)setupNavBar {
    self.navigationItem.title = @"收货地址";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickSaveButton:)];
}

- (void)setupSubviews {
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *nib = [UINib nibWithNibName:@"TCShippingAddressEditViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TCShippingAddressEditViewCell"];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCShippingAddressEditViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCShippingAddressEditViewCell" forIndexPath:indexPath];
    cell.nameTextField.delegate = self;
    cell.phoneTextField.delegate = self;
    cell.detailAddressTextView.delegate = self;
    cell.delegate = self;
    if (self.shippingAddressType == TCShippingAddressTypeEdit) {
        TCUserShippingAddress *shippingAddress = self.shippingAddress;
        cell.nameTextField.text = shippingAddress.name;
        cell.phoneTextField.text = shippingAddress.phone;
        NSString *province = shippingAddress.province ?: @"";
        NSString *city = shippingAddress.city ?: @"";
        NSString *district = shippingAddress.district ?: @"";
        cell.addressLabel.text = [NSString stringWithFormat:@"%@%@%@", province, city, district];
        cell.detailAddressTextView.text = shippingAddress.address;
    }
    self.cell = cell;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 202;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([textView isFirstResponder]) {
            [textView resignFirstResponder];
        }
    }
    return YES;
}

#pragma mark - TCShippingAddressEditViewCellDelegate

- (void)didTapAddressViewInShippingAddressEditViewCell:(TCShippingAddressEditViewCell *)cell {
    if ([self.cell.nameTextField isFirstResponder]) {
        [self.cell.nameTextField resignFirstResponder];
    }
    if ([self.cell.phoneTextField isFirstResponder]) {
        [self.cell.phoneTextField resignFirstResponder];
    }
    if ([self.cell.detailTextLabel isFirstResponder]) {
        [self.cell.detailTextLabel resignFirstResponder];
    }
    [self showPickerView];
}

#pragma mark - TCCityPickerViewDelegate

- (void)cityPickerView:(TCCityPickerView *)view didClickConfirmButtonWithCityInfo:(NSDictionary *)cityInfo {
    if (self.shippingAddress == nil) {
        self.shippingAddress = [[TCUserShippingAddress alloc] init];
    }
    self.shippingAddress.province = cityInfo[TCCityPickierViewProvinceKey];
    self.shippingAddress.city = cityInfo[TCCityPickierViewCityKey];
    self.shippingAddress.district = cityInfo[TCCityPickierViewCountryKey];
    self.cell.addressLabel.text = [NSString stringWithFormat:@"%@%@%@", self.shippingAddress.province, self.shippingAddress.city, self.shippingAddress.district];
    [self dismissPickerView];
}

- (void)didClickCancelButtonInCityPickerView:(TCCityPickerView *)view {
    [self dismissPickerView];
}

#pragma mark - Picker View

- (void)showPickerView {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *pickerBgView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    pickerBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [keyWindow addSubview:pickerBgView];
    self.pickerBgView = pickerBgView;
    
    TCCityPickerView *cityPickerView = [[[NSBundle mainBundle] loadNibNamed:@"TCCityPickerView" owner:nil options:nil] firstObject];
    cityPickerView.delegate = self;
    cityPickerView.frame = CGRectMake(0, TCScreenHeight, TCScreenWidth, 240);
    [keyWindow addSubview:cityPickerView];
    self.cityPickerView = cityPickerView;
    
    [UIView animateWithDuration:0.25 animations:^{
        pickerBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.82];
        cityPickerView.y = TCScreenHeight - cityPickerView.height;
    }];
}

- (void)dismissPickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.cityPickerView.y = TCScreenHeight;
    } completion:^(BOOL finished) {
        [self.pickerBgView removeFromSuperview];
        [self.cityPickerView removeFromSuperview];
    }];
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickSaveButton:(UIBarButtonItem *)sender {
    if (self.cell.nameTextField.text.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请填写收货人姓名！"];
        return;
    }
    if (self.cell.phoneTextField.text.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请填写手机号码！"];
        return;
    }
    if (self.cell.addressLabel.text.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请填写所在地！"];
        return;
    }
    if (self.cell.addressLabel.text.length == 0) {
        [MBProgressHUD showHUDWithMessage:@"请填写详细地址！"];
        return;
    }
    
    if (self.shippingAddress == nil) {
        self.shippingAddress = [[TCUserShippingAddress alloc] init];
    }
    self.shippingAddress.name = self.cell.nameTextField.text;
    self.shippingAddress.phone = self.cell.phoneTextField.text;
    self.shippingAddress.address = self.cell.detailAddressTextView.text;
    
    if (self.shippingAddressType == TCShippingAddressTypeAdd) {
        [self addShippingAddress];
    } else {
        [self editShippingAddress];
    }
}

- (void)addShippingAddress {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] addUserShippingAddress:self.shippingAddress result:^(BOOL success, TCUserShippingAddress *shippingAddress, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            if (weakSelf.shippingAddressBlock) {
                weakSelf.shippingAddressBlock(TCShippingAddressTypeAdd, shippingAddress);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [MBProgressHUD showHUDWithMessage:@"添加收货地址失败！"];
        }
    }];
}

- (void)editShippingAddress {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] changeUserShippingAddress:self.shippingAddress result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            if (weakSelf.shippingAddressBlock) {
                weakSelf.shippingAddressBlock(TCShippingAddressTypeEdit, self.shippingAddress);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [MBProgressHUD showHUDWithMessage:@"修改收货地址失败！"];
        }
    }];
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
