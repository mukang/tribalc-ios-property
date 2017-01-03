//
//  TCPropertyManageListController.m
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPropertyManageListController.h"
#import "TCBuluoApi.h"
#import "TCPropertyManageWrapper.h"
#import "TCPropertyManageCell.h"
#import "TCRefreshHeader.h"
#import "TCRefreshFooter.h"
#import "TCPropertyDetailController.h"

@interface TCPropertyManageListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *propertyTableView;

@property (nonatomic, strong) TCPropertyManageWrapper *propertymanageWrapper;

@property (nonatomic, strong) NSArray *currentList;

@end

@implementation TCPropertyManageListController

- (UITableView *)propertyTableView {
    if (_propertyTableView == nil) {
        _propertyTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"物业报修";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
    [self loadDataIsMore:NO];
}

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadDataIsMore:(BOOL)isMore {
    [MBProgressHUD showHUD:YES];
    @WeakObj(self)
    NSString *skip = isMore ? self.propertymanageWrapper.nextSkip : nil;
    [[TCBuluoApi api] fetchPropertyWrapper:nil count:20 sortSkip:skip result:^(TCPropertyManageWrapper *propertyManageWrapper, NSError *error) {
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
    [self.navigationController pushViewController:propertyDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCPropertyManage *propertyManage = self.currentList[indexPath.section];
    NSString *status = propertyManage.status;
    CGFloat height = 0.0;
    if ([status isEqualToString:@"ORDER_ACCEPT"]) {
         height = 225.00;
    }else {
        if ([status isEqualToString:@"PAY_ED"] && propertyManage.totalFee) {
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

- (void)dealloc {
    TCLog(@"TCPropertyManageListController--dealloc");
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
