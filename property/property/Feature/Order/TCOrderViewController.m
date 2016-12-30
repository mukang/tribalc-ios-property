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


@interface TCOrderViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *propertyTableView;

@property (nonatomic, strong) TCPropertyManageWrapper *propertymanageWrapper;

@property (nonatomic, strong) NSArray *currentList;

@property (nonatomic, assign) NSInteger index;

@end

@implementation TCOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                    };
    _index = 0;
    [self setUpTopView];
    [self loadDataIsMore:NO];
    
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
    @WeakObj(self)
    tab.tapBlock = ^(NSInteger index){
        @StrongObj(self)
        self.index = index;
        [self loadDataIsMore:NO];
    };
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
    if ([status isEqualToString:@"ORDER_ACCEPT"]) {
        height = 225.00;
    }else {
        if ([status isEqualToString:@"PAYED"] && propertyManage.totalFee) {
            height = 342;
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
