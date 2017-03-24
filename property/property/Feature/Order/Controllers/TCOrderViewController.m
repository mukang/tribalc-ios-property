//
//  TCOrderViewController.m
//  property
//
//  Created by 王帅锋 on 16/12/28.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCOrderViewController.h"
#import "TCTabView.h"
#import "TCPropertyManageWrapper.h"
#import "TCRefreshFooter.h"
#include "TCRefreshHeader.h"
#import "TCBuluoApi.h"
#import "TCPropertyManageCell.h"
#import "TCPropertyDetailController.h"
#import "TCCommonButton.h"

@interface TCOrderViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) TCTabView *tab;
@property (nonatomic, strong) UITableView *propertyTableView;

@property (nonatomic, strong) TCPropertyManageWrapper *propertymanageWrapper;

@property (nonatomic, strong) NSArray *currentList;

@property (nonatomic, assign) NSInteger index;

@property (weak, nonatomic) UILabel *promptLabel;
@property (weak, nonatomic) TCCommonButton *bindButton;

@end

@implementation TCOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = TCBackgroundColor;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                    };
    
    
    _index = 0;
    [self setUpTopView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[TCBuluoApi api] currentUserSession].userInfo.companyID) {
        self.tab.hidden = NO;
        self.propertyTableView.hidden = NO;
        [self loadDataIsMore:NO];
    } else {
        self.tab.hidden = YES;
        self.propertyTableView.hidden = YES;
        [self setupPromptView];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UITableView *)propertyTableView {
    if (_propertyTableView == nil) {
        _propertyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TCRealValue(42), self.view.bounds.size.width, self.view.bounds.size.height-TCRealValue(42)) style:UITableViewStyleGrouped];
        _propertyTableView.delegate = self;
        _propertyTableView.dataSource = self;
        _propertyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_propertyTableView];
        [self setupTableViewRefreshView];
        UINib *nib = [UINib nibWithNibName:@"TCPropertyManageCell" bundle:[NSBundle mainBundle]];
        [_propertyTableView registerNib:nib forCellReuseIdentifier:@"propertyManageCell"];
    }
    return _propertyTableView;
}

- (void)loadDataIsMore:(BOOL)isMore {
    [MBProgressHUD showHUD:YES];
    @WeakObj(self)
    
    if (self.promptLabel.hidden == NO) {
        self.promptLabel.hidden = YES;
    }
    
    NSString *type = nil;
    if (_index == 0) {
        type = @"NEW_ORDER";
    }else if (_index == 1) {
        type = @"PROCESSING_ORDER";
    }else if (_index == 2) {
        type = @"FINISHED_ORDER";
    }
    
    NSString *skip = isMore ? self.propertymanageWrapper.nextSkip : nil;
    [[TCBuluoApi api] fetchPropertyWrapper:type count:20 sortSkip:skip result:^(TCPropertyManageWrapper *propertyManageWrapper, NSError *error) {
        @StrongObj(self)
        if (propertyManageWrapper) {
            [MBProgressHUD hideHUD:YES];
            self.propertymanageWrapper = propertyManageWrapper;
            
            if (isMore) {
                NSMutableArray *mutableArr = [NSMutableArray arrayWithArray:self.currentList];
                [mutableArr addObjectsFromArray:propertyManageWrapper.content];
                self.currentList = mutableArr;
                [self.propertyTableView.mj_footer endRefreshing];
            }else {
                self.currentList = propertyManageWrapper.content;
                [self.propertyTableView.mj_header endRefreshing];
                self.propertyTableView.mj_footer.hidden = NO;
            }
            [self.propertyTableView reloadData];
            
        }else {
            if (isMore) {
                [self.propertyTableView.mj_footer endRefreshing];
            }else {
                [self.propertyTableView.mj_header endRefreshing];
            }
            [MBProgressHUD showHUDWithMessage:@"获取订单失败！"];
        }
    }];
}

- (void)setUpTopView {
    TCTabView *tab = [[TCTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, TCRealValue(42)) titleArr:@[@"新订单",@"进行中",@"已结束"]];
    [self.view addSubview:tab];
    self.tab = tab;
    @WeakObj(self)
    tab.tapBlock = ^(NSInteger index){
        @StrongObj(self)
        self.index = index;
        [self loadDataIsMore:NO];
    };
}

- (void)setupPromptView {
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.text = @"绑定公司成功后，才可查看订单信息\n请到“我的公司”中申请绑定";
    promptLabel.textColor = TCBlackColor;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont systemFontOfSize:16];
    promptLabel.numberOfLines = 0;
    [self.view addSubview:promptLabel];
    self.promptLabel = promptLabel;
    
//    TCCommonButton *bindButton = [TCCommonButton buttonWithTitle:@"绑定公司" target:self action:@selector(handleClickBindButton:)];
//    [self.view addSubview:bindButton];
//    self.bindButton = bindButton;
    
    __weak typeof(self) weakSelf = self;
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view.mas_top).with.offset(TCRealValue(180));
    }];
//    [bindButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.view.mas_top).with.offset(300);
//        make.left.equalTo(weakSelf.view.mas_left).with.offset(30);
//        make.right.equalTo(weakSelf.view.mas_right).with.offset(-30);
//        make.height.mas_equalTo(40);
//    }];
}

- (void)setupTableViewRefreshView {
    @WeakObj(self)
    TCRefreshHeader *refreshHeader = [TCRefreshHeader headerWithRefreshingBlock:^(void) {
        @StrongObj(self)
        [self loadDataIsMore:NO];
    }];
    _propertyTableView.mj_header = refreshHeader;
    
    TCRefreshFooter *refreshFooter = [TCRefreshFooter footerWithRefreshingBlock:^(void) {
        @StrongObj(self)
        if (self.propertymanageWrapper.hasMore) {
            [self loadDataIsMore:YES];
        }else {
            [self.propertyTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    }];
    refreshFooter.hidden = YES;
    _propertyTableView.mj_footer = refreshFooter;
}

#pragma UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCPropertyManage *propertyManage = self.currentList[indexPath.section];
    TCPropertyDetailController *propertyDetailVC = [[TCPropertyDetailController alloc] initWithPropertyManage:propertyManage];
    propertyDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:propertyDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCPropertyManage *propertyManage = self.currentList[indexPath.section];
    NSString *status = propertyManage.status;
    CGFloat height = 0.0;
    if ([status isEqualToString:@"ORDER_ACCEPT"] || [status isEqualToString:@"CANCEL"]) {
        height = 225.00;
    }else {
        if (([status isEqualToString:@"PAY_ED"] || [status isEqualToString:@"TO_PAYING"]) && propertyManage.totalFee>0) {
            height = 350.0;
        }else {
            height = 320.0;
        }
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] init];
    v.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);
    v.backgroundColor = [UIColor colorWithRed:237/255.0 green:239/255.0 blue:240/255.0 alpha:1.0];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.00;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.currentList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCPropertyManageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"propertyManageCell" forIndexPath:indexPath];
    TCPropertyManage *propertyManage = self.currentList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.propertyManage = propertyManage;
    return cell;
}

#pragma mark - Actions

- (void)handleClickBindButton:(TCCommonButton *)sender {
    
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
