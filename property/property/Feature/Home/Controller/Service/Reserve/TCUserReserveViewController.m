//
//  TCUserReserveViewController.m
//  individual
//
//  Created by WYH on 16/12/1.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserReserveViewController.h"
#import "TCGetNavigationItem.h"
#import "TCUserReserveTableViewCell.h"
#import "TCUserReserveDetailViewController.h"
#import "TCComponent.h"
#import "TCBuluoApi.h"
#import "TCImageURLSynthesizer.h"
#import "TCRecommendHeader.h"
#import "TCRecommendFooter.h"
#import "UIImage+Category.h"

@interface TCUserReserveViewController ()

@end

@implementation TCUserReserveViewController {
    TCReservationWrapper *userReserveWrapper;
//    NSArray *userReserveOrderArr;
    UITableView *reserveTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initReservationData];
    
    [self initNavigationBar];
    [self initTableView];
    
}


- (void)initReservationData {
    [MBProgressHUD showHUD:YES];
//    [[TCBuluoApi api] fetchReservationWrapper:nil limiSize:20 sortSkip:nil result:^(TCReservationWrapper *wrapper, NSError *error) {
//        if (wrapper) {
//            [MBProgressHUD hideHUD:YES];
//            userReserveWrapper = wrapper;
//            [reserveTableView reloadData];
//            [reserveTableView.mj_header endRefreshing];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取预订列表失败, %@", reason]];
//        }
//    }];
}

- (void)loadReservationData {
    
    if (userReserveWrapper.hasMore) {
//        [[TCBuluoApi api] fetchReservationWrapper:nil limiSize:20 sortSkip:userReserveWrapper.nextSkip result:^(TCReservationWrapper *wrapper, NSError *error) {
//            if (wrapper) {
//                NSArray *contentArr = userReserveWrapper.content;
//                userReserveWrapper = wrapper;
//                userReserveWrapper.content = [contentArr arrayByAddingObjectsFromArray:wrapper.content];
//                [reserveTableView reloadData];
//            } else {
//                NSString *reason = error.localizedDescription ?: @"请稍后再试";
//                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取预订列表失败, %@", reason]];
//            }
//        }];
    } else {
        TCRecommendFooter *footer = (TCRecommendFooter *)reserveTableView.mj_footer;
        [footer setTitle:@"已加载全部" forState:MJRefreshStateRefreshing];
    }
    [reserveTableView.mj_footer endRefreshing];

}


- (void)initNavigationBar {
    self.title = @"我的预订";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(touchBackBtn)];
    
}

- (void)initTableView {
    reserveTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64) style:UITableViewStyleGrouped];
    reserveTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    reserveTableView.delegate = self;
    reserveTableView.dataSource = self;
    reserveTableView.backgroundColor = [UIColor whiteColor];
    [self initRefreshTableView];
    
    [self.view addSubview:reserveTableView];
    
}

- (void)initRefreshTableView {
    __weak TCUserReserveViewController *weakSelf = self;
    TCRecommendHeader *refreshHeader = [TCRecommendHeader headerWithRefreshingBlock:^(void) {
        [weakSelf initReservationData];
    }];
    reserveTableView.mj_header = refreshHeader;
    
    TCRecommendFooter *refreshFooter = [TCRecommendFooter footerWithRefreshingBlock:^(void) {
        [weakSelf loadReservationData];
    }];
    reserveTableView.mj_footer = refreshFooter;
}

- (NSString *)getHeaderStatusText:(NSString *)text {
    if ([text isEqualToString:@"PROCESSING"]) {
        return @"预订处理中";
    } else if ([text isEqualToString:@"CANCEL"]){
        return @"订座取消";
    } else if ([text isEqualToString:@"FAILURE"]) {
        return @"订座失败";
    } else {
        return @"订座成功";
    }
}

- (UIColor *)getHeaderStatusTextColor:(NSString *)text {
    if ([text isEqualToString:@"PROCESSING"]) {
        return TCRGBColor(242, 68, 69);
    } else if ([text isEqualToString:@"FAILURE"] || [text isEqualToString:@"CANCEL"]) {
        return TCRGBColor(154, 154, 154);
    } else {
        return TCRGBColor(81, 199, 209);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *reserveArr = userReserveWrapper.content;
    return reserveArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *identifier = [NSString stringWithFormat:@"header%li", (long)section];
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
    }
    NSArray *userReserveOrderArr = userReserveWrapper.content;
    TCReservation *reservation = userReserveOrderArr[section];
    UILabel *statusLab = [TCComponent createLabelWithFrame:CGRectMake(TCRealValue(22.5), 0, TCScreenWidth - TCRealValue(45), TCRealValue(42)) AndFontSize:TCRealValue(14) AndTitle:[self getHeaderStatusText:reservation.status]];
    statusLab.textColor = [self getHeaderStatusTextColor:reservation.status];
    [headerView addSubview:statusLab];
    UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(0, TCRealValue(42 - 0.5), TCScreenWidth, TCRealValue(0.5))];
    [headerView addSubview:topLineView];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *identifier = [NSString stringWithFormat:@"footer%li", (long)section];
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!footerView) {
        footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TCScreenWidth, TCRealValue(7))];
    backView.backgroundColor = TCRGBColor(242, 242, 242);
    [footerView addSubview:backView];
    
    return footerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    TCUserReserveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TCUserReserveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSArray *userReserveOrderArr = userReserveWrapper.content;
    TCReservation *reservation = userReserveOrderArr[indexPath.section];
    NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:reservation.mainPicture];
    UIImage *placeholderImage = [UIImage placeholderImageWithSize:CGSizeMake(TCRealValue(169), TCRealValue(115))];
    [cell.storeImageView sd_setImageWithURL:URL placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    [cell setTitleLabText:reservation.storeName];
    [cell setBrandLabText:reservation.markPlace];
    if (reservation.tags.count == 0) {
        [cell setPlaceLabText:nil];
    } else {
        [cell setPlaceLabText:reservation.tags[0]];
    }
    cell.timeLab.text = [self getTimeStr:reservation.appointTime / 1000];
    cell.personNumberLab.text = [NSString stringWithFormat:@"%li", (long)reservation.personNum];
    
    return cell;
}

- (NSString *)getTimeStr:(long)timeInt {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInt];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TCRealValue(143);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TCRealValue(42);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TCRealValue(7);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TCReservation *reservation = userReserveWrapper.content[indexPath.section];
    TCUserReserveDetailViewController *reserveDetailViewController = [[TCUserReserveDetailViewController alloc] initWithReservationId:reservation.ID];
    [self.navigationController pushViewController:reserveDetailViewController animated:YES];
}

#pragma mark - Click

- (void)touchBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
