//
//  TCCompanyViewController.m
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyViewController.h"

#import "TCCompanyHeaderView.h"
#import "TCCompanyIntroViewCell.h"
#import "TCCompanyTitleViewCell.h"
#import "TCCompanyEmployeesViewCell.h"

#import "TCUserCompanyInfo.h"
#import "TCCompanyInfo.h"
#import "TCBuluoApi.h"

#import "UIImage+Category.h"

#import <UITableView+FDTemplateLayoutCell.h>

@interface TCCompanyViewController () <UITableViewDataSource, UITableViewDelegate, TCCompanyIntroViewCellDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) TCUserCompanyInfo *userCompanyInfo;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) TCCompanyHeaderView *headerView;

@property (nonatomic) CGFloat headerViewHeight;
@property (nonatomic) CGFloat topBarHeight;

@property (weak, nonatomic) UINavigationBar *navBar;
@property (weak, nonatomic) UINavigationItem *navItem;
@property (nonatomic) BOOL needsLightContentStatusBar;

@property (nonatomic) BOOL companyIntroFold;

@end

@implementation TCCompanyViewController {
    __weak TCCompanyViewController *weakSelf;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    weakSelf = self;
    self.headerViewHeight = TCRealValue(270);
    self.topBarHeight = 64.0;
    self.companyIntroFold = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavBar];
    [self setupSubviews];
    [self loadData];
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.hideOriginalNavBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth, 64)];
    [navBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    [self.view addSubview:navBar];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.userCompanyInfo.company.companyName];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(handleCickBackButton:)];
    navItem.leftBarButtonItem = leftItem;
    [navBar setItems:@[navItem]];
    
    self.navBar = navBar;
    self.navItem = navItem;
    
    [self updateNavigationBarWithAlpha:0.0];
}

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = TCRGBColor(242, 242, 242);
    tableView.separatorColor = TCRGBColor(221, 221, 221);
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tableView registerClass:[TCCompanyIntroViewCell class] forCellReuseIdentifier:@"TCCompanyIntroViewCell"];
    [tableView registerClass:[TCCompanyTitleViewCell class] forCellReuseIdentifier:@"TCCompanyTitleViewCell"];
    [tableView registerClass:[TCCompanyEmployeesViewCell class] forCellReuseIdentifier:@"TCCompanyEmployeesViewCell"];
    [self.view insertSubview:tableView belowSubview:self.navBar];
    self.tableView = tableView;
    
    TCCompanyHeaderView *headerView = [[TCCompanyHeaderView alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth, self.headerViewHeight)];
    tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)loadData {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] fetchCompanyBlindStatus:^(TCUserCompanyInfo *userCompanyInfo, NSError *error) {
        if (userCompanyInfo) {
            [MBProgressHUD hideHUD:YES];
            weakSelf.userCompanyInfo = userCompanyInfo;
            self.headerView.companyInfo = userCompanyInfo.company;
            self.navigationItem.title = userCompanyInfo.company.companyName;
            [weakSelf.tableView reloadData];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"加载失败，%@", reason]];
        }
    }];
}

#pragma mark - Navigation Bar

- (void)updateNavigationBar {
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat alpha = offsetY / (self.headerViewHeight - self.topBarHeight);
    if (alpha > 1.0) alpha = 1.0;
    if (alpha < 0.0) alpha = 0.0;
    [self updateNavigationBarWithAlpha:alpha];
}

- (void)updateNavigationBarWithAlpha:(CGFloat)alpha {
    UIColor *tintColor = nil, *titleColor = nil;
    if (alpha > 0.7) {
        self.needsLightContentStatusBar = YES;
        tintColor = [UIColor whiteColor];
        titleColor = [UIColor whiteColor];
    } else {
        self.needsLightContentStatusBar = NO;
        tintColor = TCRGBColor(42, 42, 42);
        titleColor = [UIColor clearColor];
    }
    [self.navBar setTintColor:tintColor];
    self.navBar.titleTextAttributes = @{
                                        NSFontAttributeName : [UIFont systemFontOfSize:16],
                                        NSForegroundColorAttributeName : titleColor
                                        };
    
    UIImage *bgImage = [UIImage imageWithColor:TCARGBColor(42, 42, 42, alpha)];
    [self.navBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Status Bar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.needsLightContentStatusBar ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setNeedsLightContentStatusBar:(BOOL)needsLightContentStatusBar {
    BOOL statusBarNeedsUpdate = (needsLightContentStatusBar != _needsLightContentStatusBar);
    _needsLightContentStatusBar = needsLightContentStatusBar;
    if (statusBarNeedsUpdate) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TCCompanyIntroViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCompanyIntroViewCell" forIndexPath:indexPath];
        cell.fold = self.companyIntroFold;
        cell.companyInfo = self.userCompanyInfo.company;
        cell.delegate = self;
        return cell;
    } else {
        if (indexPath.row == 0) {
            TCCompanyTitleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCompanyTitleViewCell" forIndexPath:indexPath];
            return cell;
        } else {
            TCCompanyEmployeesViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCompanyEmployeesViewCell" forIndexPath:indexPath];
            switch (indexPath.row) {
                case 1:
                    cell.titleLabel.text = @"公司名称";
                    cell.subtitleLabel.text = self.userCompanyInfo.company.companyName;
                    break;
                case 2:
                    cell.titleLabel.text = @"姓名";
                    cell.subtitleLabel.text = [[TCBuluoApi api] currentUserSession].userInfo.name;
                    break;
                case 3:
                    cell.titleLabel.text = @"部门";
                    cell.subtitleLabel.text = self.userCompanyInfo.department;
                    break;
                case 4:
                    cell.titleLabel.text = @"职位";
                    cell.subtitleLabel.text = self.userCompanyInfo.position;
                    break;
                case 5:
                    cell.titleLabel.text = @"门卡号码";
                    cell.subtitleLabel.text = self.userCompanyInfo.personNum;
                    break;
                    
                default:
                    break;
            }
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [tableView fd_heightForCellWithIdentifier:@"TCCompanyIntroViewCell" configuration:^(id cell) {
            TCCompanyIntroViewCell *companyIntroViewCell = cell;
            companyIntroViewCell.fold = self.companyIntroFold;
            companyIntroViewCell.companyInfo = weakSelf.userCompanyInfo.company;
        }];
    } else {
        if (indexPath.row == 0) {
            return 42;
        } else {
            return 37;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 7;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavigationBar];
}

#pragma mark - TCCompanyIntroViewCellDelegate

- (void)companyIntroViewCell:(TCCompanyIntroViewCell *)cell didClickUnfoldButtonWithFold:(BOOL)fold {
    self.companyIntroFold = !fold;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)handleCickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
