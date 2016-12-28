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
    
    [self setData];
    
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
    
    if (_propertyManage.status) {
        if ([_propertyManage.status isEqualToString:@"ORDER_ACCEPT"]) {
            _masterView.hidden = YES;
            _payBtn.hidden = YES;
        }else if ([_propertyManage.status isEqualToString:@"TASK_CONFIRM"]) {
            _masterView.hidden = NO;
            _payBtn.hidden = YES;
        }else if ([_propertyManage.status isEqualToString:@"NOT_PAYING"]) {
            _masterView.hidden = NO;
            _payBtn.hidden = NO;
            btnH = 30.0;
            btnBottomC = 86.5;
        }else if ([_propertyManage.status isEqualToString:@"PAYED"]) {
            _masterView.hidden= NO;
            _payBtn.hidden = YES;
        }else {
            _masterView.hidden = YES;
            _payBtn.hidden = YES;
        }
    }else {
        _masterView.hidden = YES;
        _payBtn.hidden = YES;
    }
    
    _btnHeightConstraint.constant = btnH;
    _btnBottomConstraint.constant = btnBottomC;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}

- (IBAction)payBtnClick:(id)sender {
    TCPaymentViewController *paymentVc = [[TCPaymentViewController alloc] init];
    [self.navigationController pushViewController:paymentVc animated:YES];
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
