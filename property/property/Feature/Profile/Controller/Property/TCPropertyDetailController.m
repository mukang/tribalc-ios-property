//
//  TCPropertyDetailController.m
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPropertyDetailController.h"
#import "TCPropertyManage.h"
#import "TCImageURLSynthesizer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TCPaymentViewController.h"
#import "TCBuluoApi.h"

@interface TCPropertyDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *communityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *applyPersonNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *imgView;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet UILabel *masterPersonNameLabe;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *doorTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *problemDescBtn;

@property (nonatomic, strong) TCPropertyManage *propertyManage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageVConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *problemDescHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doorTimeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fixProjectLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *applyPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *masterHeightConstraint;

@end

@implementation TCPropertyDetailController

- (instancetype)initWithPropertyManage:(TCPropertyManage *)property {
    self = [super initWithNibName:@"TCPropertyDetailController" bundle:[NSBundle mainBundle]];
    if (self) {
        _propertyManage = property;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"物业订单";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
    
    [self loadDetail];
    
}

- (void)loadDetail {
    [MBProgressHUD showHUD:YES];
    @WeakObj(self)
    [[TCBuluoApi api] fetchPropertyDetailWithOrderId:_propertyManage.ID result:^(TCPropertyManage *propertyManage, NSError *error) {
        @StrongObj(self)
        if (propertyManage) {
            [MBProgressHUD hideHUD:YES];
            _propertyManage = propertyManage;
            [self setData];
        }else {
            [MBProgressHUD showHUDWithMessage:error.localizedDescription? error.localizedDescription : @"获取订单详情失败，请稍后再试"];
        }
    }];
}

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setData {
    NSTimeInterval appointTime = _propertyManage.appointTime/1000;
    NSDate *appointDate = [NSDate dateWithTimeIntervalSince1970:appointTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSTimeInterval doorTime = _propertyManage.doorTime/1000;
    NSDate *doorDate = [NSDate dateWithTimeIntervalSince1970:doorTime];
    _communityNameLabel.text = _propertyManage.communityName ? _propertyManage.communityName : @"";
    _companyNameLabel.text =  _propertyManage.companyName ? _propertyManage.companyName : @"";
    _applyPersonNameLabel.text = _propertyManage.applyPersonName ? _propertyManage.applyPersonName : @"";
    _floorLabel.text = _propertyManage.floor ? [NSString stringWithFormat:@"%@层",_propertyManage.floor] : @"";
    _appointTimeLabel.text = [formatter stringFromDate:appointDate];
    _phoneLabel.text = _propertyManage.phone;  
    _masterPersonNameLabe.text = _propertyManage.masterPersonName ? _propertyManage.masterPersonName : @"";
    _doorTimeLabel.text = [formatter stringFromDate:doorDate];
    if (_propertyManage.fixProject) {
        if ([_propertyManage.fixProject isEqualToString:@"PIPE_FIX"]) {
            _fixProjectLabel.text = @"管件维修";
        }else if ([_propertyManage.fixProject isEqualToString:@"PUBLIC_LIGHTING"]) {
            _fixProjectLabel.text = @"公共照明";
        }else if ([_propertyManage.fixProject isEqualToString:@"WATER_PIPE_FIX"]) {
            _fixProjectLabel.text = @"水管维修";
        }else if ([_propertyManage.fixProject isEqualToString:@"ELECTRICAL_FIX"]) {
            _fixProjectLabel.text = @"电器维修";
        }else {
            _fixProjectLabel.text = @"其他";
        }
    }else {
        _fixProjectLabel.text = @"";
    }
    _masterView.hidden = [_propertyManage.status isEqualToString:@"ORDER_ACCEPT"];
    _payBtn.layer.cornerRadius = 3.0;
    _payBtn.clipsToBounds = YES;
    _problemDescBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    
    
    NSString *problemDesc = _propertyManage.problemDesc ? _propertyManage.problemDesc : @"";
    NSDictionary *attribute1 = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize size1 = [problemDesc boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-80, 9999.0) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute1 context:nil].size;
    _problemDescHeightConstraint.constant = size1.height+40.0;
    _problemDescBtn.titleLabel.numberOfLines = 0;
    [_problemDescBtn setTitle:problemDesc forState:UIControlStateNormal];
    
    CGFloat height = 0.0;
    
    if ([_propertyManage.pictures isKindOfClass:[NSArray class]]) {
        NSArray *arr = _propertyManage.pictures;
        if (arr.count > 0) {
            for (int i =0; i < arr.count; i++) {
                NSString *imgStr = arr[i];
                if ([imgStr isKindOfClass:[NSString class]]) {
                    if (![imgStr isEqualToString:@""]) {
                        _imgView.hidden = NO;
                        height = [UIScreen mainScreen].bounds.size.width/375.0*102.5;
                        NSURL *imageURL = [TCImageURLSynthesizer synthesizeImageURLWithPath:imgStr];
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+(height + 5) * i, 0, height, height)];
                        [_imgView addSubview:imageView];
                        imageView.layer.cornerRadius = 3.0;
                        imageView.clipsToBounds = YES;
                        [imageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRetryFailed];
                    }
                }
                
            }
        }else {
            _imgView.hidden = YES;
            height = 0.0;
        }
    }else {
        height = 0.0;
        _imgView.hidden = YES;
    }
    
    _imageVConstraint.constant = height;
    
    CGFloat btnH = 0.0;
    CGFloat btnBottomC = 0.0;
    CGFloat btnTopC = 30.0;
    CGFloat masterHC = 0.0;
    if (_propertyManage.status) {
        if ([_propertyManage.status isEqualToString:@"ORDER_ACCEPT"]) {
            _masterView.hidden = YES;
            _payBtn.hidden = NO;
            btnH = 30.0;
            masterHC = 0.0;
            [_payBtn setTitle:@"接单" forState:UIControlStateNormal];
            [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_payBtn setBackgroundColor:TCRGBColor(88, 191, 200)];
            
        }else if ([_propertyManage.status isEqualToString:@"TASK_CONFIRM"]) {
            _masterView.hidden = NO;
            _payBtn.hidden = NO;
            [_payBtn setTitle:@"维修" forState:UIControlStateNormal];
            [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_payBtn setBackgroundColor:TCRGBColor(88, 191, 200)];
            //已接单
            
            
        }else if ([_propertyManage.status isEqualToString:@"NOT_PAYING"]) {
            _masterView.hidden = NO;
            _payBtn.hidden = NO;
            btnH = 30.0;
            btnBottomC = 86.5;
            btnTopC = 50;
            //待支付
            if (_propertyManage.totalFee) {
                UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, CGRectGetMaxY(_masterView.frame), self.view.bounds.size.width-120, 20)];
                moneyLabel.font = [UIFont systemFontOfSize:14];
                [self.view addSubview:moneyLabel];
                moneyLabel.textColor = TCRGBColor(42, 42, 42);
                NSString *moneyStr = [NSString stringWithFormat:@"维修金额¥%@",_propertyManage.totalFee];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString: moneyStr];
                [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[moneyStr rangeOfString:_propertyManage.totalFee]];
                [att addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[moneyStr rangeOfString:_propertyManage.totalFee]];
                moneyLabel.attributedText = att;
                
            }
            [_payBtn setTitle:@"待支付" forState:UIControlStateNormal];
            [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_payBtn setBackgroundColor:TCRGBColor(88, 191, 200)];
            
            
        }else if ([_propertyManage.status isEqualToString:@"PAYED"]) {
            _masterView.hidden= NO;
            _payBtn.hidden = YES;
            //已完成
            if (_propertyManage.totalFee) {
                UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, CGRectGetMaxY(_masterView.frame), self.view.bounds.size.width-120, 20)];
                moneyLabel.font = [UIFont systemFontOfSize:14];
                [self.view addSubview:moneyLabel];
                moneyLabel.textColor = TCRGBColor(42, 42, 42);
                NSString *moneyStr = [NSString stringWithFormat:@"维修金额¥%@",_propertyManage.totalFee];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString: moneyStr];
                [att addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[moneyStr rangeOfString:_propertyManage.totalFee]];
                [att addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[moneyStr rangeOfString:_propertyManage.totalFee]];
                moneyLabel.attributedText = att;
                
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_masterView.frame)-75, -35, 75, 75)];
            imageView.image = [UIImage imageNamed:@"propertyManageFinished"];
            [_masterView addSubview:imageView];
            
            
        }else if ([_propertyManage.status isEqualToString:@"NOT_FIX"]) {
            _masterView.hidden = YES;
            _payBtn.hidden = YES;
            //待维修
        }
    }else {
        _masterView.hidden = YES;
        _payBtn.hidden = YES;
    }
    
    _btnHeightConstraint.constant = btnH;
    _btnBottomConstraint.constant = btnBottomC;
    _btnTopConstraint.constant = btnTopC;
    _masterHeightConstraint.constant = masterHC;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}

- (void)acceptOrder {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] updatePropertyInfoWithOrderId:_propertyManage.ID status:@"TASK_CONFIRM" doorTime:nil result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            
        }else {
            [MBProgressHUD showHUDWithMessage:error.localizedDescription ? error.localizedDescription : @"接单失败"];
        }
        [self loadDetail];
    }];
}

- (void)comfirmFixTime {

}

- (IBAction)payBtnClick:(id)sender {
    if (_propertyManage.status) {
        if ([_propertyManage.status isEqualToString:@"ORDER_ACCEPT"]) {
            //接单
            [self acceptOrder];
        }else if ([_propertyManage.status isEqualToString:@"TASK_CONFIRM"]) {
        //确定维修时间
            [self comfirmFixTime];
        }else if ([_propertyManage.status isEqualToString:@"NOT_PAYING"]) {
         //待付款
            TCPaymentViewController *paymentVc = [[TCPaymentViewController alloc] init];
            [self.navigationController pushViewController:paymentVc animated:YES];

        }
    }
}

- (void)dealloc {
    TCLog(@"TCPropertyDetailCOntroller--dealloc");
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
