//
//  TCBioEditLocationViewController.m
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBioEditLocationViewController.h"
#import "TCCommonInputViewCell.h"
#import "TCCityPickerView.h"
#import "TCBuluoApi.h"
#import <Masonry.h>

@interface TCBioEditLocationViewController () <UITableViewDataSource, UITableViewDelegate, TCCommonInputViewCellDelegate, TCCityPickerViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) TCCityPickerView *pickerView;

@property (nonatomic) BOOL pickerViewShow;

@end

@implementation TCBioEditLocationViewController {
    __weak TCBioEditLocationViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    weakSelf = self;
    
    [self setupNavBar];
    [self setupSubviews];
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.navigationItem.title = @"所在地";
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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = TCRGBColor(242, 242, 242);
    tableView.separatorColor = TCRGBColor(221, 221, 221);
    tableView.rowHeight = 50;
    tableView.dataSource = self;
    tableView.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"TCCommonInputViewCell" bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forCellReuseIdentifier:@"TCCommonInputViewCell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    TCCityPickerView *pickerView = [[[NSBundle mainBundle] loadNibNamed:@"TCCityPickerView" owner:nil options:nil] firstObject];
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
    self.pickerView = pickerView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
    
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view.mas_bottom);
        make.height.mas_equalTo(220);
    }];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCCommonInputViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCommonInputViewCell" forIndexPath:indexPath];
    cell.title = @"所在地";
    cell.placeholder = @"请选择所在地";
    if (self.address) {
        cell.content = [NSString stringWithFormat:@"%@%@%@", self.address.province, self.address.city, self.address.district];
    }
    cell.inputEnabled = NO;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - TCCommonInputViewCellDelegate

- (void)didTapContainerViewInCommonInputViewCell:(TCCommonInputViewCell *)cell {
    if (self.pickerViewShow) return;
    
    self.pickerViewShow = YES;
    [self handlePickerViewShow:self.pickerViewShow];
}

#pragma mark - TCCityPickerViewDelegate

- (void)cityPickerView:(TCCityPickerView *)view didClickConfirmButtonWithCityInfo:(NSDictionary *)cityInfo {
    TCUserAddress *address = [[TCUserAddress alloc] init];
    address.province = cityInfo[TCCityPickierViewProvinceKey];
    address.city = cityInfo[TCCityPickierViewCityKey];
    address.district = cityInfo[TCCityPickierViewCountryKey];
    
    self.address = address;
    [self.tableView reloadData];
}

- (void)didClickCancelButtonInCityPickerView:(TCCityPickerView *)view {
    self.pickerViewShow = NO;
    [self handlePickerViewShow:self.pickerViewShow];
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickSaveButton:(UIBarButtonItem *)sender {
    if (!self.address) {
        return;
    }
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] changeUserAddress:self.address result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            if (weakSelf.editLocationBlock) {
                weakSelf.editLocationBlock();
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"所在地修改失败，%@", reason]];
        }
    }];
}

- (void)handlePickerViewShow:(BOOL)isShow {
    CGFloat bottomOffset;
    if (isShow) {
        bottomOffset = -220;
    } else {
        bottomOffset = 0;
    }
    
    [weakSelf.pickerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_bottom).with.offset(bottomOffset);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf.view layoutIfNeeded];
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
