//
//  TCUserReserveDetailViewController.m
//  individual
//
//  Created by WYH on 16/12/4.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserReserveDetailViewController.h"
#import "TCComponent.h"
#import "TCGetNavigationItem.h"
#import "TCImageURLSynthesizer.h"
#import "TCUserReserveTableViewCell.h"
#import "TCReserveOnlineViewController.h"
#import "TCBuluoApi.h"
#import "TCOrderDetailAlertView.h"
#import "UIImage+Category.h"

@interface TCUserReserveDetailViewController () {
//    UITableView *reserveDetailTableView;
//    NSDictionary *reserveDetailDic;
    NSString *mReservationId;
    TCReservationDetail *reservationDetail;
}

@end

@implementation TCUserReserveDetailViewController {
    __weak TCUserReserveDetailViewController *weakSelf;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    self.view.backgroundColor = [UIColor whiteColor];

}

- (instancetype)initWithReservationId:(NSString *)reservationId {
    self = [super init];
    if (self) {
        mReservationId = reservationId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    weakSelf = self;
    
    [self initNavigationBar];
    
    [self initReservationDetail];
}


- (void)initReservationDetail {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] fetchReservationDetail:mReservationId result:^(TCReservationDetail *reservation, NSError *error) {
        if (reservation) {
            [MBProgressHUD hideHUD:YES];
            reservationDetail = reservation;
            [weakSelf initUI];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取预订详情失败, %@", reason]];
        }
        
    }];
}


- (void)initUI {
    UIScrollView *mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    mScrollView.backgroundColor = TCRGBColor(242, 242, 242);
    [self.view addSubview:mScrollView];
    
    
    UIView *statusView = [self getStatusViewWithStatus:[self getTitleStatusStr]];
    [mScrollView addSubview:statusView];
    
    UITableView *mTableView = [self getReserveDetailTableView];
    [mScrollView addSubview:mTableView];
    
    UIView *customerView = [self getContactCustomerServiceViewWithFrame:CGRectMake(0, mTableView.y + mTableView.height, self.view.width, TCRealValue(44))];
    [mScrollView addSubview:customerView];
    
    
    if (![reservationDetail.status isEqualToString:@"CANCEL"] && ![reservationDetail.status isEqualToString:@"FAILURE"]) {
        UIButton *cancelBtn =[self getCancelOrderBtnWithFrame:CGRectMake(self.view.width / 2 - TCRealValue(315) / 2, customerView.y + customerView.height, TCRealValue(315), TCRealValue(40))];
        [mScrollView addSubview:cancelBtn];
    }
    
    mScrollView.contentSize = CGSizeMake(TCScreenWidth, mTableView.y + mTableView.height + TCRealValue(104));


}

- (void)initNavigationBar {
    self.title = @"我的预订";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(touchBackBtn)];
}

- (NSString *)getTitleStatusStr {
    if ([reservationDetail.status isEqualToString:@"PROCESSING"]) {
        return @"订座处理中";
    } else if ([reservationDetail.status isEqualToString:@"SUCCEED"]) {
        return @"订座完成";
    } else {
        return @"订座失败";
    }
}

- (UITableView *)getReserveDetailTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TCRealValue(71), self.view.width, TCRealValue(131 + 11) + TCRealValue(11 + 66 + 40 * 5)) style:UITableViewStylePlain];
    tableView.userInteractionEnabled = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return tableView;
}

- (UIButton *)getCancelOrderBtnWithFrame:(CGRect)frame {
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:frame];
    cancelBtn.backgroundColor = TCRGBColor(81, 199, 209);
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消订单" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(16)];
    cancelBtn.layer.cornerRadius = TCRealValue(5);
    [cancelBtn addTarget:self action:@selector(touchCancelReserve:) forControlEvents:UIControlEventTouchUpInside];
    
    return cancelBtn;
}

- (UIView *)getContactCustomerServiceViewWithFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UILabel *tagLab = [TCComponent createLabelWithText:@"有问题请联系客服 : " AndFontSize:TCRealValue(12)];
    tagLab.textColor = TCRGBColor(154, 154, 154);
    UIButton *phoneBtn = [[UIButton alloc] init];
    [phoneBtn setTitle:@"4008-252-987" forState:UIControlStateNormal];
    [phoneBtn setTitleColor:TCRGBColor(81, 199, 209) forState:UIControlStateNormal];
    phoneBtn.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    [phoneBtn sizeToFit];
    
    tagLab.frame = CGRectMake(self.view.width / 2 - (tagLab.width + phoneBtn.width) / 2, 0, tagLab.width, view.height);
    phoneBtn.frame = CGRectMake(tagLab.x + tagLab.width, 0, phoneBtn.width, view.height);
    [view addSubview:tagLab];
    [view addSubview:phoneBtn];
    
    return view;
}


- (UIView *)getStatusViewWithStatus:(NSString *)status {
    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TCRealValue(71))];
    statusView.backgroundColor = TCRGBColor(242, 242, 242);
    UILabel *statusLab = [TCComponent createLabelWithText:status AndFontSize:TCRealValue(14)];
    statusLab.frame = CGRectMake(self.view.width / 2 - (statusLab.width + TCRealValue(17)) / 2, TCRealValue(20), statusLab.width, TCRealValue(14));
    [statusView addSubview:statusLab];
    
    UIImageView *statusImgView = [[UIImageView alloc] initWithFrame:CGRectMake(statusLab.x - TCRealValue(17), statusLab.y, TCRealValue(14), TCRealValue(14))];
    statusImgView.image = [UIImage imageNamed:[self getStatusImgName:status]];
    [statusView addSubview:statusImgView];
    
    UILabel *statusPromptLab = [TCComponent createLabelWithFrame:CGRectMake(0, statusView.height - TCRealValue(15) - TCRealValue(12), self.view.width, TCRealValue(12)) AndFontSize:TCRealValue(12) AndTitle:[self getStatusPrompt:status] AndTextColor:TCRGBColor(125, 125, 125)];
    statusPromptLab.textAlignment = NSTextAlignmentCenter;
    [statusView addSubview:statusPromptLab];
    
    
    return statusView;
}

- (NSString *)getStatusPrompt:(NSString *)statusStr {
    if ([statusStr isEqualToString:@"订座处理中"]) {
        return @"预计在5分钟内通过短信告知您的订单结果";
    } else if ([statusStr isEqualToString:@"订座完成"]) {
        return @"恭喜您的订座已完成 请您按时间到达☺";
    } else {
        return @"订餐未能按指定要求安排座位";
    }
}

- (NSString *)getStatusImgName:(NSString *)statusStr {
    if ([statusStr isEqualToString:@"订座处理中"]) {
        return @"reserve_handle";
    } else if ([statusStr isEqualToString:@"订座完成"]) {
        return @"reserve_complete";
    } else {
        return @"reserve_fail";
    }
}


- (UITableViewCell *)getTableViewCellForReserveDetail {
//    TCUserReserveTableViewCell *cell = [[TCUserReserveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    TCUserReserveTableViewCell *cell = [[TCUserReserveTableViewCell alloc] initReserveDetail];
    cell.backgroundColor = [UIColor whiteColor];
//    cell.storeImageView.frame = CGRectMake(cell.storeImageView.x + 8, 131 / 2 - 109.5 / 2, cell.storeImageView.width - 8, 109.5);
    NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:reservationDetail.mainPicture];
    UIImage *placeholderImage = [UIImage placeholderImageWithSize:CGSizeMake(TCRealValue(169), TCRealValue(115))];
    [cell.storeImageView sd_setImageWithURL:URL placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    cell.timeLab.text = [self getTimeStr:reservationDetail.appointTime / 1000];
    cell.personNumberLab.text = [NSString stringWithFormat:@"%li", (long)reservationDetail.personNum];
    [cell setTitleLabText:reservationDetail.storeName];
    [cell setDetailBrandLabText:reservationDetail.markPlace];
    if (reservationDetail.tags.count != 0) {
        [cell setDetailPlaceLabText:reservationDetail.tags[0]];
    } else {
        [cell setDetailPlaceLabText:nil];
    }

    
    return cell;
}

- (NSString *)getTimeStr:(long)timeInt {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInt];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];
}


- (UITableViewCell *)getTableViewCellForBaseInfo:(NSDictionary *)infoDic {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *titleLab = [TCComponent createLabelWithText:infoDic[@"title"] AndFontSize:TCRealValue(12)];
    titleLab.frame = CGRectMake(TCRealValue(20), 0, titleLab.width, TCRealValue(40));
    [cell addSubview:titleLab];
    
    UILabel *detailLab = [TCComponent createLabelWithText:infoDic[@"detail"] AndFontSize:TCRealValue(12)];
    detailLab.frame = CGRectMake(titleLab.x + titleLab.width + TCRealValue(20), 0, self.view.width - titleLab.x - titleLab.width - TCRealValue(40), TCRealValue(40));
    detailLab.textAlignment = NSTextAlignmentRight;
    [cell addSubview:detailLab];
    
    UIView *bottomLineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), TCRealValue(40 - 0.5), self.view.width - TCRealValue(40), TCRealValue(0.5))];
    [cell addSubview:bottomLineView];
    if ([infoDic[@"title"] isEqualToString:@"联系电话"]) {
        bottomLineView.frame = CGRectMake(0, TCRealValue(40 - 0.5), self.view.width, TCRealValue(0.5));
    }
    
    return cell;
}

- (UITableViewCell *)getTableViewCellForAddressInfo:(NSDictionary *)infoDic {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *titleLab = [TCComponent createLabelWithFrame:CGRectMake(TCRealValue(20), TCRealValue(13), TCRealValue(25), TCRealValue(12)) AndFontSize:TCRealValue(12) AndTitle:infoDic[@"title"]];
    [cell addSubview:titleLab];
    UILabel *addressLab = [self getAddressLabelWithText:infoDic[@"detail"]];
    [cell addSubview:addressLab];
    
    UIView *bottomView = [self getTableBottomViewWithFrame:CGRectMake(0, TCRealValue(66), self.view.width, TCRealValue(11))];
    [cell addSubview:bottomView];
    
    return cell;
}

- (UILabel *)getAddressLabelWithText:(NSString *)text {
    UILabel *addressLab = [[UILabel alloc] initWithFrame:CGRectMake(TCRealValue(20 + 28 + 25), TCRealValue(10), self.view.width - TCRealValue(45) - TCRealValue(28) - TCRealValue(20), TCRealValue(40))];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = TCRealValue(9);
    NSRange range = NSMakeRange(0, text.length);
    [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:range];
    addressLab.numberOfLines = TCRealValue(2);
    addressLab.lineBreakMode = NSLineBreakByWordWrapping;
    addressLab.font = [UIFont systemFontOfSize:TCRealValue(12)];
    addressLab.attributedText = attrStr;
    
    return addressLab;
}

- (NSArray *)getReserveArray {
    NSString *personNumStr = [NSString stringWithFormat:@"%li", (long)reservationDetail.personNum];
    NSString *addressStr = reservationDetail.address ? reservationDetail.address : @"";
    NSDictionary *timeDic = [self getReserveDetailDicWithTitle:@"时间" AndDetail:[self getTimeStringWithTimeStamp:reservationDetail.appointTime]];
    NSDictionary *numberDic = [self getReserveDetailDicWithTitle:@"人数" AndDetail:personNumStr];
    NSDictionary *resDic = [self getReserveDetailDicWithTitle:@"餐厅" AndDetail:reservationDetail.storeName];
    NSDictionary *addressDic = [self getReserveDetailDicWithTitle:@"地点" AndDetail:addressStr];
    NSDictionary *contactsDic = [self getReserveDetailDicWithTitle:@"联系人" AndDetail:reservationDetail.linkman];
    NSDictionary *phoneDic = [self getReserveDetailDicWithTitle:@"联系电话" AndDetail:reservationDetail.phone];
    return @[timeDic, numberDic, resDic, addressDic, contactsDic, phoneDic];
}

- (NSDictionary *)getReserveDetailDicWithTitle:(NSString *)title AndDetail:(NSString *)detail {
    detail = detail ? detail : @"";
    return @{ @"title":title, @"detail": detail };
}

- (NSString *)getTimeStringWithTimeStamp:(NSInteger)timeStamp {
    if (!timeStamp) {
        return @"";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (UIView *)getTableBottomViewWithFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = TCRGBColor(242, 242, 242);
    UIView *bottomLineView = [TCComponent createGrayLineWithFrame:CGRectMake(0, view.height - TCRealValue(0.5), view.width, TCRealValue(0.5))];
    UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(0, 0, view.width, TCRealValue(0.5))];
    [view addSubview:bottomLineView];
    [view addSubview:topLineView];
    
    return view;
}

- (void)changeReservationStatus:(NSString *)status {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] changeReservationStatus:status ReservationId:reservationDetail.ID result:^(BOOL result, NSError *error) {
        if (result) {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            [MBProgressHUD showHUDWithMessage:@"取消订单成功"];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"取消订单失败, %@", reason]];

        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [self getTableViewCellForReserveDetail];
    } else {
        NSArray *reserveDetailArr = [self getReserveArray];
        if (indexPath.row != 4) {
            return [self getTableViewCellForBaseInfo:reserveDetailArr[indexPath.row - 1]];
        } else {
            return [self getTableViewCellForAddressInfo:reserveDetailArr[indexPath.row - 1]];
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return TCRealValue(131 + 11);
    } else if (indexPath.row == 4) {
        return TCRealValue(66 + 11);
    } else {
        return TCRealValue(40);
    }
}

#pragma mark - TCOrderDetailAlertViewDelegate
- (void)alertView:(TCOrderDetailAlertView *)alertView didSelectOptionButtonWithTag:(NSInteger)tag {
    switch (tag) {
        case 0:
            [alertView removeFromSuperview];
            break;
        case 1:
            [self changeReservationStatus:@"CANCEL"];
            [alertView removeFromSuperview];
            
        default:
            break;
    }
}


- (void)touchBackBtn {
    NSArray *navigationArr = self.navigationController.viewControllers;
    if ([navigationArr[navigationArr.count - 2] isKindOfClass:[TCReserveOnlineViewController class]]) {
        UIViewController *viewController = navigationArr[navigationArr.count - 3];
        [self.navigationController popToViewController:viewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)touchCancelReserve:(UIButton *)button {
    TCOrderDetailAlertView *orderDetailAlertView = [[TCOrderDetailAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    orderDetailAlertView.delegate = self;
    [orderDetailAlertView show];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
