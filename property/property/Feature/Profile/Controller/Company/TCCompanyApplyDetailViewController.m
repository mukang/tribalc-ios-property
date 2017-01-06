//
//  TCCompanyApplyDetailViewController.m
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyApplyDetailViewController.h"
#import "TCCommunityListViewController.h"
#import "TCCompanyApplyViewController.h"

#import "TCCommonButton.h"
#import "TCCommonInputViewCell.h"
#import "TCCompanyApplyTitleViewCell.h"
#import "TCCompanyApplyNameViewCell.h"

#import "TCBuluoApi.h"

#import <Masonry.h>

typedef NS_ENUM(NSInteger, TCInputCellType) {
    TCInputCellTypeName = 1,
    TCInputCellTypeDepartment,
    TCInputCellTypePosition,
    TCInputCellTypeJobNum
};

@interface TCCompanyApplyDetailViewController () <UITableViewDataSource, UITableViewDelegate, TCCommonInputViewCellDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) TCCommonButton *commitButton;

@property (strong, nonatomic) TCUserCompanyInfo *userCompanyInfo;

@end

@implementation TCCompanyApplyDetailViewController {
    __weak TCCompanyApplyDetailViewController *weakSelf;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    weakSelf = self;
    self.userCompanyInfo = [[TCUserCompanyInfo alloc] init];
    
    [self setupNavBar];
    [self setupSubviews];
    [self setupConstraints];
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.navigationItem.title = @"我的公司";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
}

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = TCRGBColor(242, 242, 242);
    tableView.separatorColor = TCRGBColor(221, 221, 221);
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TCCompanyApplyTitleViewCell class] forCellReuseIdentifier:@"TCCompanyApplyTitleViewCell"];
    [tableView registerClass:[TCCompanyApplyNameViewCell class] forCellReuseIdentifier:@"TCCompanyApplyNameViewCell"];
    [tableView registerNib:[UINib nibWithNibName:@"TCCommonInputViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TCCommonInputViewCell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    TCCommonButton *commitButton = [TCCommonButton buttonWithTitle:@"绑定" target:self action:@selector(handleClickCommitButton:)];
    [self.view addSubview:commitButton];
    self.commitButton = commitButton;
}

- (void)setupConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
    [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view.mas_left).with.offset(30);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-30);
        make.bottom.equalTo(weakSelf.view.mas_bottom).with.offset(TCRealValue(-70));
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TCCompanyApplyTitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCompanyApplyTitleViewCell" forIndexPath:indexPath];
        return cell;
    } else {
        if (indexPath.row == 0) {
            TCCompanyApplyNameViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCompanyApplyNameViewCell" forIndexPath:indexPath];
            cell.nameLabel.text = self.userCompanyInfo.company.companyName;
            return cell;
        } else {
            TCCommonInputViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCommonInputViewCell" forIndexPath:indexPath];
            switch (indexPath.row) {
                case TCInputCellTypeName:
                    cell.title = @"姓名";
                    cell.content = [[TCBuluoApi api] currentUserSession].userInfo.name;
                    cell.inputEnabled = NO;
                    break;
                case TCInputCellTypeDepartment:
                    cell.title = @"部门";
                    cell.placeholder = @"请输入部门名称";
                    cell.content = self.userCompanyInfo.department;
                    cell.inputEnabled = YES;
                    break;
                case TCInputCellTypePosition:
                    cell.title = @"职位";
                    cell.placeholder = @"请输入职位";
                    cell.content = self.userCompanyInfo.position;
                    cell.inputEnabled = YES;
                    break;
                case TCInputCellTypeJobNum:
                    cell.title = @"工号";
                    cell.placeholder = @"请输入工号";
                    cell.content = self.userCompanyInfo.personNum;
                    cell.inputEnabled = YES;
                    break;
                    
                default:
                    break;
            }
            cell.delegate = self;
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 67;
    } else {
        return 45;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 6;
    } else {
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView endEditing:YES];
        TCCommunityListViewController *vc = [[TCCommunityListViewController alloc] init];
        vc.popToVC = self;
        vc.companyInfoBlock = ^(TCCompanyInfo *companyInfo, TCCommunity *community) {
            weakSelf.userCompanyInfo.company = companyInfo;
            weakSelf.userCompanyInfo.community = community;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - TCCommonInputViewCellDelegate

- (void)commonInputViewCell:(TCCommonInputViewCell *)cell textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    switch (indexPath.row) {
        case TCInputCellTypeDepartment:
            self.userCompanyInfo.department = textField.text;
            break;
        case TCInputCellTypePosition:
            self.userCompanyInfo.position = textField.text;
            break;
        case TCInputCellTypeJobNum:
            self.userCompanyInfo.personNum = textField.text;
            break;
            
        default:
            break;
    }
}

- (BOOL)commonInputViewCell:(TCCommonInputViewCell *)cell textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView endEditing:YES];
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickCommitButton:(TCCommonButton *)sender {
    if (!self.userCompanyInfo.company.ID) {
        [MBProgressHUD showHUDWithMessage:@"请选择需要绑定的公司"];
        return;
    }
    
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] bindCompanyWithUserCompanyInfo:self.userCompanyInfo result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD showHUDWithMessage:@"绑定成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *vc = weakSelf.navigationController.childViewControllers[0];
                [weakSelf.navigationController popToViewController:vc animated:YES];
            });
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"绑定失败，%@", reason]];
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
