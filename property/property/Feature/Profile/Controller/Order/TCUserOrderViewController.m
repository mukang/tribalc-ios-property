//
//  TCOrderViewController.m
//  individual
//
//  Created by WYH on 16/11/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserOrderViewController.h"
#import "TCBuluoApi.h"
#import "TCModelImport.h"
#import "TCImageURLSynthesizer.h"
#import "TCRecommendHeader.h"
#import "TCRecommendFooter.h"

@interface TCUserOrderViewController () {
//    TCOrderWrapper *mOrderWrapper;
    NSString *mStatus;
}

@end

@implementation TCUserOrderViewController



//- (instancetype)initWithStatus:(NSString *)statusStr {
//    self = [super init];
//    if (self) {
//        mStatus = statusStr;
//    }
//    
//    return self;
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self initTableView];
//
//    [self initOrderItem];
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.tabBarController.tabBar.hidden = YES;
//    
//}
//
//- (void)initOrderItem {
//    TCBuluoApi *api = [TCBuluoApi api];
//    [MBProgressHUD showHUD:YES];
//    [api fetchOrderWrapper:mStatus limiSize:20 sortSkip:nil result:^(TCOrderWrapper *orderWrapper, NSError *error) {
//        if (orderWrapper) {
//            [MBProgressHUD hideHUD:YES];
//            mOrderWrapper = orderWrapper;
//            [orderTableView reloadData];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取订单列表失败, %@", reason]];
//        }
//        [orderTableView.mj_header endRefreshing];
//        
//    }];
//}
//
//- (void)setupOrderItem {
//    if (mOrderWrapper.hasMore) {
//        TCBuluoApi *api = [TCBuluoApi api];
//        [api fetchOrderWrapper:mStatus limiSize:20 sortSkip:mOrderWrapper.nextSkip result:^(TCOrderWrapper *orderWrapper, NSError *error){
//            if (orderWrapper) {
//                NSArray *beforeContentArr = mOrderWrapper.content;
//                mOrderWrapper = orderWrapper;
//                mOrderWrapper.content = [beforeContentArr arrayByAddingObjectsFromArray:orderWrapper.content];
//                [orderTableView reloadData];
//                
//            } else {
//                NSString *reason = error.localizedDescription ?: @"请稍后再试";
//                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取订单列表失败, %@", reason]];
//            }
//        }];
//    } else {
//        TCRecommendFooter *footer = (TCRecommendFooter *)orderTableView.mj_footer;
//        [footer setTitle:@"已加载全部" forState:MJRefreshStateRefreshing];
//    }
//    [orderTableView.mj_footer endRefreshing];
//
//}
//
//- (void)initTableView {
//    orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TCRealValue(40.5), self.view.width, self.view.height- TCRealValue(40.5)) style:UITableViewStyleGrouped];
//    orderTableView.showsHorizontalScrollIndicator = NO;
//    orderTableView.delegate = self;
//    orderTableView.dataSource = self;
//    orderTableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
//    orderTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
//    orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    orderTableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
//    [self.view addSubview:orderTableView];
//    
//    [self setupTableViewRefreshView];
//}
//
//- (void)setupTableViewRefreshView {
//    TCRecommendHeader *refreshHeader = [TCRecommendHeader headerWithRefreshingBlock:^(void) {
//        [self initOrderItem];
//    }];
//    orderTableView.mj_header = refreshHeader;
//    
//    TCRecommendFooter *refreshFooter = [TCRecommendFooter footerWithRefreshingBlock:^(void) {
//        [self setupOrderItem];
//    }];
//    orderTableView.mj_footer = refreshFooter;
//}
//
//- (UIView *)getTableViewFooterViewWithTotalprice:(NSString *)totalPrice {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TCRealValue(51))];
//    UILabel *totalLab = [self getOrderTotalPriceLabelWithPrice:totalPrice];
//    [view addSubview:totalLab];
//    
//    UILabel *totalMarkLab = [TCComponent createLabelWithFrame:CGRectMake(self.view.width - totalLab.width - TCRealValue(47), TCRealValue(2), TCRealValue(30), view.height - TCRealValue(3)) AndFontSize:TCRealValue(12) AndTitle:@"总计:" AndTextColor:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1]];
//    [view addSubview:totalMarkLab];
//    
//    return view;
//}
//
//- (UILabel *)getOrderTotalPriceLabelWithPrice:(NSString *)totalPrice  {
//    UILabel *totalLab = [TCComponent createLabelWithText:[NSString stringWithFormat:@"￥%@", totalPrice] AndFontSize:TCRealValue(18)];
//    totalLab.font = [UIFont fontWithName:BOLD_FONT size:TCRealValue(18)];
//    totalLab.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
//    [totalLab sizeToFit];
//    totalLab.frame = CGRectMake(self.view.width - TCRealValue(20) - totalLab.width, 0, totalLab.width, TCRealValue(51));
//    
//    return totalLab;
//}
//
//- (UIView *)getTableViewHeightViewWithOrderId:(NSString *)orderIdStr AndStatus:(NSString *)statusStr{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TCRealValue(40.5) + TCRealValue(15))];
//    UIView *orderInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, TCRealValue(15), self.view.width, view.frame.size.height - TCRealValue(15))];
//    orderInfoView.backgroundColor = [UIColor whiteColor];
//    UILabel *orderIdLab = [TCComponent createLabelWithFrame:CGRectMake(TCRealValue(20), 0, self.view.width - TCRealValue(79), orderInfoView.height) AndFontSize:TCRealValue(14) AndTitle:[NSString stringWithFormat:@"订单号:%@", orderIdStr] AndTextColor:[UIColor blackColor]];
//    [orderInfoView addSubview:orderIdLab];
//    
//    if (![self.title isEqualToString:@"全部"]) {
//        statusStr = [self getStatusWithText:statusStr];
//    } else {
//        statusStr = [self getStatusForAllTabWithText:statusStr];
//    }
//    
//    UIView *statusView = [self getOrderStatusViewWithStatus:statusStr];
//    [orderInfoView addSubview:statusView];
//    
//    [view addSubview:orderInfoView];
//    
//    return view;
//}
//
//- (NSString *)getStatusForAllTabWithText:(NSString *)text {
//    if ([text isEqualToString:@"NO_SETTLE"]) {
//        return @"等待付款";
//    } else if ([text isEqualToString:@"DELIVERY"]) {
//        return @"等待收货";
//    } else if ([text isEqualToString:@"SETTLE"]) {
//        return @"等待发货";
//    } else if ([text isEqualToString:@"CANCEL"]) {
//        return @"订单已取消";
//    }
//     else{
//        return text;
//    }
//
//}
//
//- (NSString *)getStatusWithText:(NSString *)text {
//    if ([text isEqualToString:@"NO_SETTLE"]) {
//        return @"等待买家付款";
//    } else if ([text isEqualToString:@"DELIVERY"]) {
//        return @"卖家已发货";
//    } else if ([text isEqualToString:@"SETTLE"]) {
//        return @"等待卖家发货";
//    } else if ([text isEqualToString:@"CANCEL"]) {
//        return @"订单已取消";
//    }
//    else{
//        return text;
//    }
//}
//
//- (UIView *)getOrderStatusViewWithStatus:(NSString *)statusStr {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.view.width - TCRealValue(79), 0, TCRealValue(79), TCRealValue(40.5))];
//    if ([statusStr isEqualToString:@"RECEIVED"]) {
//        UIImage *completeImg = [UIImage imageNamed:@"order_complete"];
//        UIImageView *statusImgView = [[UIImageView alloc] initWithImage:completeImg];
//        statusImgView.frame = CGRectMake((view.width - completeImg.size.width) / 2, (view.height - completeImg.size.height) / 2, completeImg.size.width, completeImg.size.height);
//        [view addSubview:statusImgView];
//    } else {
//        UILabel *statusLabel = [TCComponent createLabelWithFrame:CGRectMake(TCRealValue(-60), 0, view.width + TCRealValue(40), view.height) AndFontSize:TCRealValue(14) AndTitle:statusStr AndTextColor:[UIColor colorWithRed:81/255.0 green:199/255.0 blue:209/255.0 alpha:1]];
//        statusLabel.textAlignment = NSTextAlignmentRight;
//        [view addSubview:statusLabel];
//    }
//    
//    return view;
//}
//
//#pragma mark - UITableView
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return TCRealValue(77);
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return TCRealValue(40.5 + 15);
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return TCRealValue(51);
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSArray *contentArr = mOrderWrapper.content;
//    TCOrder *order = contentArr[section];
//    NSString *statusStr = order.status;
//    UIView *heightView = [self getTableViewHeightViewWithOrderId:order.orderNum AndStatus:statusStr];
//    heightView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
//    return heightView;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    NSArray *contentArr = mOrderWrapper.content;
//    TCOrder *order = contentArr[section];
//    NSString *totalFeeStr = [NSString stringWithFormat:@"%@", @([NSString stringWithFormat:@"%f", order.totalFee].floatValue)];
//    UIView *footerView = [self getTableViewFooterViewWithTotalprice:totalFeeStr];
//    footerView.backgroundColor = [UIColor whiteColor];
//    return footerView;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *orderContentArr = mOrderWrapper.content;
//    TCOrder *order = orderContentArr[section];
//    NSArray *itemList = order.itemList;
//    
//    return itemList.count;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSArray *orderContentArr = mOrderWrapper.content;
//    return orderContentArr.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TCUserOrderTableViewCell *cell = [TCUserOrderTableViewCell cellWithTableView:tableView];
//    NSArray *orderContentArr = mOrderWrapper.content;
//    TCOrder *order = orderContentArr[indexPath.section];
//    NSArray *itemList = order.itemList;
//    TCOrderItem *orderItem = itemList[indexPath.row];
//    [cell setOrderListOrderItem:orderItem];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    NSArray *orderContentArr = mOrderWrapper.content;
//    TCOrder *order = orderContentArr[indexPath.section];
//    
//    
//    TCUserOrderDetailViewController *orderDetailViewController = [[TCUserOrderDetailViewController alloc] initWithOrder:order];
//    orderDetailViewController.title = @"订单详情";
//    [self.navigationController pushViewController:orderDetailViewController animated:YES];
//    
//}
//
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    
//}
//

@end
