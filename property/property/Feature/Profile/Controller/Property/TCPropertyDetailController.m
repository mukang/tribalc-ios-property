//
//  TCPropertyDetailController.m
//  individual
//
//  Created by 王帅锋 on 16/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPropertyDetailController.h"
#import "TCPropertyManage.h"
#import <TCCommonLibs/TCImageURLSynthesizer.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TCPaymentViewController.h"
#import "TCBuluoApi.h"
#import <TCCommonLibs/TCDatePickerView.h>
#import "TCOrderCancelView.h"
#import <TCCommonLibs/UIImage+Category.h>
#import "TCImagePreviewObject.h"
#import "TCImagePreviewController.h"

@interface TCPropertyDetailController () <TCDatePickerViewDelegate,UITextFieldDelegate,TCImagePreviewControllerDelegate>
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

@property (strong, nonatomic) UILabel *moneyLabel;

@property (nonatomic, strong) UITextField *textField;

@property (assign, nonatomic) NSTimeInterval timestamp;

@property (strong, nonatomic) TCOrderCancelView *cancelView;

@property (weak, nonatomic) IBOutlet UIImageView *overImageView;

@property (copy, nonatomic) NSArray *imagePreViewObjectArr;

@property (weak, nonatomic) UIView *selectedView;

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animation;

@end

@implementation TCPropertyDetailController

- (instancetype)initWithPropertyManage:(TCPropertyManage *)property {
    self = [super initWithNibName:@"TCPropertyDetailController" bundle:[NSBundle mainBundle]];
    if (self) {
        _propertyManage = property;
    }
    return self;
}


#pragma mark - transition animation

-(BOOL)isTransitionAnimationSupport
{
    return YES;
}

-(id<UIViewControllerAnimatedTransitioning>)pushTransitionAnimationSupport
{
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
//        return nil;
//    }
    return self.animation;
}

-(id<UIViewControllerAnimatedTransitioning>)popTransitionAnimationSupport
{
    return nil;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.delegate = [TCNavigationDelegate shareDelegate];
    self.title = @"物业订单";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
    _timestamp = 0.0;
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

- (void)cancelWithReason:(NSString *)str {
    @WeakObj(self)
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] cancelPropertyOrderWithOrderID:_propertyManage.ID reason:str result:^(BOOL success, NSError *error) {
        @StrongObj(self)
        if (success) {
            [self.cancelView removeFromSuperview];
            self.cancelView = nil;
            [MBProgressHUD showHUDWithMessage:@"取消成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else {
            [MBProgressHUD hideHUD:YES];
            [MBProgressHUD showHUDWithMessage:@"取消失败"];
        }
    }];
}

- (void)cancelOrder {
    @WeakObj(self)
    _cancelView = [[TCOrderCancelView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.size.width, self.navigationController.view.size.height)];
    _cancelView.cancelBlock = ^{
        @StrongObj(self)
        [self.cancelView removeFromSuperview];
        self.cancelView = nil;
    };
    _cancelView.confirmBlock = ^(NSString *str){
        @StrongObj(self)
        [self cancelWithReason:str];
    };
    [self.navigationController.view addSubview:_cancelView];
}

- (void)setData {
    
    if (![_propertyManage.status isEqualToString:@"PAY_ED"] && ![_propertyManage.status isEqualToString:@"ORDER_ACCEPT"] && ![_propertyManage.status isEqualToString:@"CANCEL"] && ![_propertyManage.status isEqualToString:@"TO_PAYING"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelOrder)];
    }else {
        self.navigationItem.rightBarButtonItem = nil;
    }
        
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
    _masterView.backgroundColor = [UIColor whiteColor];
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
            
            NSMutableArray *objArr = [NSMutableArray arrayWithCapacity:0];
            for (int i =0; i < arr.count; i++) {
                NSString *imgStr = arr[i];
                if ([imgStr isKindOfClass:[NSString class]]) {
                    if (![imgStr isEqualToString:@""]) {
                        NSURL *imageURL = [TCImageURLSynthesizer synthesizeImageURLWithPath:imgStr];
                        
                        TCImagePreviewObject *obj = [[TCImagePreviewObject alloc] init];
                        obj.imageUrl = [imageURL absoluteString];
                        [objArr addObject:obj];
                        
                        _imgView.hidden = NO;
                        height = [UIScreen mainScreen].bounds.size.width/375.0*102.5;
                        
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+(height + 5) * i, 0, height, height)];
                        imageView.tag = 12345+i;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toSeeBigPhoto:)];
                        [imageView addGestureRecognizer:tap];
                        imageView.userInteractionEnabled = YES;
                        [_imgView addSubview:imageView];
                        imageView.layer.cornerRadius = 3.0;
                        imageView.clipsToBounds = YES;
                        UIImage *placeholderImage = [UIImage placeholderImageWithSize:CGSizeMake(height, height)];
                        [imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage options:SDWebImageRetryFailed];                    }
                }
                
            }
            if (objArr.count > 0) {
                _imagePreViewObjectArr = objArr;
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
    CGFloat doorTimeTopCon = 5.0;
    if (_textField) {
        [_textField removeFromSuperview];
        _textField = nil;
    }
    
    _overImageView.hidden = YES;
    if (_propertyManage.status) {
        if ([_propertyManage.status isEqualToString:@"ORDER_ACCEPT"]) {

            btnH = 30.0;
            masterHC = 0.0;
            btnBottomC = 70.0;
            [_payBtn setTitle:@"接单" forState:UIControlStateNormal];
            [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_payBtn setBackgroundColor:TCRGBColor(88, 191, 200)];
            
        }else if ([_propertyManage.status isEqualToString:@"TASK_CONFIRM"]) {

            btnH = 30.0;
            [_payBtn setTitle:@"维修" forState:UIControlStateNormal];
            [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_payBtn setBackgroundColor:TCRGBColor(88, 191, 200)];
            btnBottomC = 70.0;
            btnTopC = 30.0;
            masterHC = 115.0;
            doorTimeTopCon = 20.0;
            _doorTimeLabel.text = @"";
            //已接单
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(_doorTimeLabel.frame.origin.x, CGRectGetMaxY(_phoneLabel.frame)+15, _masterView.frame.size.width-_doorTimeLabel.frame.origin.x-5, _doorTimeLabel.frame.size.height+10)];
            textField.layer.borderColor = TCGrayColor.CGColor;
            textField.layer.cornerRadius = 3.0;
            textField.layer.borderWidth = 0.5;
            textField.clipsToBounds = YES;
            textField.delegate = self;

            textField.textAlignment = NSTextAlignmentRight;
            [_masterView addSubview:textField];
            
            UILabel *lefLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, textField.frame.size.height)];
            lefLabel.text = @"请选择";
            lefLabel.textAlignment = NSTextAlignmentRight;
            lefLabel.textColor = TCGrayColor;
            lefLabel.font = [UIFont systemFontOfSize:14];
            textField.leftView = lefLabel;
            textField.leftViewMode = UITextFieldViewModeAlways;

            UIView *rightV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
            
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 10, 18)];
            imageV.image = [UIImage imageNamed:@"indicating_arrow"];            
            [rightV addSubview:imageV];
            textField.rightView = rightV;
            textField.rightViewMode = UITextFieldViewModeAlways;
            _textField = textField;
            
            
            
        }else if ([_propertyManage.status isEqualToString:@"TO_PAYING"] || [_propertyManage.status isEqualToString:@"TO_FIX"]) {

            btnH = 30.0;
            btnBottomC = 70.0;
            btnTopC = 40;
            masterHC = 90.0;
            doorTimeTopCon = 5.0;
            //待支付
            if (_propertyManage.totalFee) {
                
                NSString *money = [NSString stringWithFormat:@"%.2f",_propertyManage.totalFee];
                if (money) {
                    NSString *s = [NSString stringWithFormat:@"维修金额 ¥%.2f",_propertyManage.totalFee];
                    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:s];
                    
                    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255 green:19/255.0 blue:19/255.0 alpha:1.0] range:NSMakeRange(5, s.length-5)];
                    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[s rangeOfString:money]];
                    NSRange r = [s rangeOfString:@"."];
                    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(r.location+r.length, s.length-r.location-1)];
                    self.moneyLabel.attributedText = attStr;
                }
                
            }
            
            if ([_propertyManage.status isEqualToString:@"TO_PAYING"]) {
                [_payBtn setTitle:@"待支付" forState:UIControlStateNormal];
            }else if ([_propertyManage.status isEqualToString:@"TO_FIX"]) {
                [_payBtn setTitle:@"去收款" forState:UIControlStateNormal];
            }
            
            
            [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_payBtn setBackgroundColor:TCRGBColor(88, 191, 200)];
            
            
        }else if ([_propertyManage.status isEqualToString:@"PAY_ED"]) {

            //已完成
            masterHC = 90.0;
            _overImageView.hidden = NO;
            _masterView.backgroundColor = TCRGBColor(238, 239, 240);
            if (_propertyManage.totalFee) {
                
                NSString *money = [NSString stringWithFormat:@"%.2f",_propertyManage.totalFee];
                if (money) {
                    NSString *s = [NSString stringWithFormat:@"维修金额 ¥%.2f",_propertyManage.totalFee];
                    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:s];
                    
                    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255 green:19/255.0 blue:19/255.0 alpha:1.0] range:NSMakeRange(5, s.length-5)];
                    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[s rangeOfString:money]];
                    NSRange r = [s rangeOfString:@"."];
                    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(r.location+r.length, s.length-r.location-1)];
                    self.moneyLabel.attributedText = attStr;
                }
                
            }
        }else if ([_propertyManage.status isEqualToString:@"CANCEL"]) {
            if (_propertyManage.phone) {
                masterHC = 90.0;
                _overImageView.hidden = YES;
                doorTimeTopCon = 5.0;
            }
            if (_propertyManage.totalFee) {
                NSString *money = [NSString stringWithFormat:@"%.2f",_propertyManage.totalFee];
                if (money) {
                    NSString *s = [NSString stringWithFormat:@"维修金额 ¥%.2f",_propertyManage.totalFee];
                    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:s];
                    
                    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:227.0/255 green:19/255.0 blue:19/255.0 alpha:1.0] range:NSMakeRange(5, s.length-5)];
                    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[s rangeOfString:money]];
                    NSRange r = [s rangeOfString:@"."];
                    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(r.location+r.length, s.length-r.location-1)];
                    self.moneyLabel.attributedText = attStr;
                }
                
            }
            btnH = 0.0;
            
        }

    }else {

    }
    
    _btnHeightConstraint.constant = btnH;
    _btnBottomConstraint.constant = btnBottomC;
    _btnTopConstraint.constant = btnTopC;
    _masterHeightConstraint.constant = masterHC;
    _doorTimeLabelTopConstraint.constant = doorTimeTopCon;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
}

-(CGRect)transitionAnimationImageEndRectWithIndex:(NSInteger)index
{
//    CGRect rect = [_selectedView.superview convertRect:_selectedView.frame toView:self.navigationController.view];
    CGRect rect = [[UIApplication sharedApplication].keyWindow convertRect:_selectedView.frame fromView:_selectedView.superview];
    rect.origin.y -= 85;
    for (UIView *view in _imgView.subviews) {
        NSInteger i = view.tag - 12345;
        if (i == index) {
            rect = [[UIApplication sharedApplication].keyWindow convertRect:view.frame fromView:view.superview];
            rect.origin.y -= 85;
        }
    }
    return rect;
}

- (void)toSeeBigPhoto:(UITapGestureRecognizer *)ges {
    UIView *view = ges.view;
    NSInteger index = view.tag-12345;
    self.selectedView = view;
    
    TCImagePreviewController *previewController = [TCImagePreviewController new];
    previewController.models = _imagePreViewObjectArr;
    previewController.currentIndex = index;
    TCImagePreviewObject *currentObj = previewController.models[previewController.currentIndex];
    
    CGRect rect = [[UIApplication sharedApplication].keyWindow convertRect:view.frame fromView:view.superview];
    rect.origin.y -= 85;
    CGRect beganRect = rect;
    previewController.delegate = self;
    self.animation = [previewController fetchTransitionAnimationWithImageUrl:[NSURL URLWithString:currentObj.imageUrl]
                                                                   beganRect:beganRect];
    
    [self.navigationController pushViewController:previewController animated:YES];
    
}

- (UILabel *)moneyLabel {
    if (_moneyLabel == nil) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = [UIFont systemFontOfSize:14];
        _moneyLabel.textAlignment = NSTextAlignmentRight;
        
        [self.view addSubview:_moneyLabel];
        [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_masterView);
            make.height.equalTo(@30);
            make.top.equalTo(_masterView.mas_bottom);
        }];
        _moneyLabel.textColor = TCBlackColor;
    }
    return _moneyLabel;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showDatePicker];
    return NO;
}

- (void)showDatePicker {
    TCDatePickerView *datePickerView = [[TCDatePickerView alloc] initWithController:self];
    datePickerView.datePicker.date = [NSDate date];
    datePickerView.datePicker.minimumDate = [NSDate date];
    datePickerView.delegate = self;
    [datePickerView show];
}

- (void)acceptOrder {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] updatePropertyInfoWithOrderId:_propertyManage.ID status:@"TASK_CONFIRM" doorTime:nil payValue:nil result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            
        }else {
            [MBProgressHUD showHUDWithMessage:error.localizedDescription ? error.localizedDescription : @"接单失败"];
        }
        [self loadDetail];
    }];
}

- (void)didClickConfirmButtonInDatePickerView:(TCDatePickerView *)view {
    _timestamp = [view.datePicker.date timeIntervalSince1970];
    if (_textField) {

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        _textField.text = [dateFormatter stringFromDate:view.datePicker.date];
    }
}

- (void)comfirmFixTime {
    if (_textField) {
        if (_textField.text.length > 0) {
            [MBProgressHUD showHUD:YES];
            [[TCBuluoApi api] updatePropertyInfoWithOrderId:_propertyManage.ID status:@"TO_FIX" doorTime:[NSString stringWithFormat:@"%ld",(NSInteger)(_timestamp * 1000) / 1000] payValue:nil result:^(BOOL success, NSError *error) {
                if (success) {
                    [MBProgressHUD hideHUD:YES];
                    [self loadDetail];
                }else {
                    [MBProgressHUD showHUDWithMessage:error.localizedDescription ? error.localizedDescription : @"确定时间失败"];
                }
                
            }];
        }else {
            [MBProgressHUD showHUDWithMessage:@"请输入维修时间"];
        }
    }
}

- (IBAction)payBtnClick:(id)sender {
    if (_propertyManage.status) {
        if ([_propertyManage.status isEqualToString:@"ORDER_ACCEPT"]) {
            //接单
            [self acceptOrder];
        }else if ([_propertyManage.status isEqualToString:@"TASK_CONFIRM"]) {
        //确定维修时间
            [self comfirmFixTime];
        }else if ([_propertyManage.status isEqualToString:@"TO_PAYING"] || [_propertyManage.status isEqualToString:@"TO_FIX"]) {
         //待付款
            TCPaymentViewController *paymentVc = [[TCPaymentViewController alloc] init];
            paymentVc.orderID = _propertyManage.ID;
            paymentVc.successBlock = ^{
                [self loadDetail];
            };
            [self.navigationController pushViewController:paymentVc animated:YES];

        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.animation = nil;
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
