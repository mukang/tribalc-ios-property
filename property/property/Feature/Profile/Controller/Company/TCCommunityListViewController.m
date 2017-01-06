//
//  TCCommunityListViewController.m
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCommunityListViewController.h"
#import "TCCompanyNameViewCell.h"
#import "TCBuluoApi.h"
#import <Masonry.h>

@interface TCCommunityListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSArray *communities;
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation TCCommunityListViewController {
    __weak TCCommunityListViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    weakSelf = self;
    
    [self setupNavBar];
    [self setupSubviews];
    [self loadNetData];
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.navigationItem.title = @"选择社区";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
}

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = TCRGBColor(242, 242, 242);
    tableView.separatorColor = TCRGBColor(221, 221, 221);
    tableView.rowHeight = 42;
    tableView.sectionHeaderHeight = 29;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[TCCompanyNameViewCell class] forCellReuseIdentifier:@"TCCompanyNameViewCell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
}

- (void)loadNetData {
//    [[TCBuluoApi api] fetchCommunityListGroupByCity:^(NSArray *communities, NSError *error) {
//        if (communities) {
//            weakSelf.communities = communities;
//            [weakSelf.tableView reloadData];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"加载失败，%@", reason]];
//        }
//    }];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.communities.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TCCommunityListInCity *communityListInCity = self.communities[section];
    return communityListInCity.communityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCCompanyNameViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCCompanyNameViewCell" forIndexPath:indexPath];
    TCCommunityListInCity *communityListInCity = self.communities[indexPath.section];
    TCCommunity *community = communityListInCity.communityList[indexPath.row];
    cell.titleLabel.text = community.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TCCompanyListViewController *vc = [[TCCompanyListViewController alloc] init];
    TCCommunityListInCity *communityListInCity = self.communities[indexPath.section];
    TCCommunity *community = communityListInCity.communityList[indexPath.row];
    vc.communityID = community.ID;
    vc.popToVC = self.popToVC;
    vc.companyInfoBlock = self.companyInfoBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TCCommunityListInCity *communityListInCity = self.communities[section];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth, 29)];
    bgView.backgroundColor = TCRGBColor(242, 242, 242);
    UILabel *cityLabel = [[UILabel alloc] init];
    cityLabel.text = communityListInCity.city;
    cityLabel.textAlignment = NSTextAlignmentLeft;
    cityLabel.textColor = TCRGBColor(42, 42, 42);
    cityLabel.font = [UIFont boldSystemFontOfSize:12];
    cityLabel.frame = CGRectMake(20, 0, bgView.width - 40, bgView.height);
    [bgView addSubview:cityLabel];
    
    return bgView;
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
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
