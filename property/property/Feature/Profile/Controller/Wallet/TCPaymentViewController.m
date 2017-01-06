//
//  TCPaymentViewController.m
//  individual
//
//  Created by 王帅锋 on 16/12/19.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCPaymentViewController.h"
#import <Masonry.h>
#import "TCBuluoApi.h"

@interface TCPaymentViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *boardView;
//@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *yueView;
@property (weak, nonatomic) IBOutlet UIButton *yueBtn;
@property (weak, nonatomic) IBOutlet UIView *wechatView;
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;
@property (weak, nonatomic) IBOutlet UIView *aliPayView;
@property (weak, nonatomic) IBOutlet UIButton *aliPayBtn;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (strong, nonatomic) UIButton *currentSelectedBtn;

@property (nonatomic, strong) UITextField *myTextField;

@end

@implementation TCPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"付款";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
    _boardView.layer.cornerRadius = 3.0;
    _boardView.clipsToBounds = YES;
    _boardView.layer.borderColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1.0].CGColor;
    _boardView.layer.borderWidth = 0.5;
    
    _myTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 26, [UIScreen mainScreen].bounds.size.width-50, 40)];
    [self.view addSubview:_myTextField];
    _myTextField.placeholder = @"请输入付款金额";
    _myTextField.delegate = self;
    _myTextField.textAlignment = NSTextAlignmentRight;
    _myTextField.font = [UIFont systemFontOfSize:14];
    _myTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
    l.text = @"付款金额";
    l.textColor = [UIColor blackColor];
    l.font = [UIFont boldSystemFontOfSize:14];
    _myTextField.leftView = l;
    _myTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _payBtn.layer.cornerRadius = 3.0;
    _payBtn.clipsToBounds = YES;
    
    UITapGestureRecognizer *tapGYE =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yueViewClick:)];
    UITapGestureRecognizer *tapGWC =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wechatViewClick:)];
    UITapGestureRecognizer *tapAL =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aliviewClick:)];
    [_yueView addGestureRecognizer:tapGYE];
    [_wechatView addGestureRecognizer:tapGWC];
    [_aliPayView addGestureRecognizer:tapAL];
    
    
    
//    UITapGestureRecognizer *returnBackGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnBack)];
//    [self.view addGestureRecognizer:returnBackGes];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([_myTextField isFirstResponder]) {
        [_myTextField resignFirstResponder];
    }
}


- (void)yueViewClick:(UITapGestureRecognizer *)ges {
    if (!_yueBtn.selected) {
        _yueBtn.selected = YES;
        _wechatBtn.selected = NO;
        _aliPayBtn.selected = NO;
        self.currentSelectedBtn = _yueBtn;
    }else {
        _yueBtn.selected = NO;
        self.currentSelectedBtn = nil;
    }
}
- (void)wechatViewClick:(UITapGestureRecognizer *)ges {
    if (!_wechatBtn.selected) {
        _wechatBtn.selected = YES;
        _yueBtn.selected = NO;
        _aliPayBtn.selected = NO;
        self.currentSelectedBtn = _wechatBtn;
    }else {
        _wechatBtn.selected = NO;
        self.currentSelectedBtn = nil;
    }
}
- (void)aliviewClick:(UITapGestureRecognizer *)ges {
    if (!_aliPayBtn.selected) {
        _aliPayBtn.selected = YES;
        _wechatBtn.selected = NO;
        _yueBtn.selected = NO;
        self.currentSelectedBtn = _aliPayBtn;
    }else {
        _aliPayBtn.selected = NO;
        self.currentSelectedBtn = nil;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        _myTextField.font = [UIFont systemFontOfSize:14];
    }
    
}

#pragma UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@",textField.text);
    NSLog(@"%@",string);
    
    
    if ([string isEqualToString:@""]) {
        if (textField.text.length == 3) {
            textField.text = nil;
        
            return NO;
        }
        
        return YES;
    }else {
        if (textField.text.length >= 15) {
            return NO;
        }
    }
    NSString *text = nil;
    if (textField.text.length == 0) {
        text = [NSString stringWithFormat:@"¥ %@",string];
    }else {
        if (range.location == 1 || range.location == 0) {
            return NO;
        }
        text = [NSString stringWithFormat:@"%@%@%@",[textField.text substringToIndex:range.location],string,[textField.text substringFromIndex:range.location]];
    }

    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1.0],NSFontAttributeName:[UIFont boldSystemFontOfSize:24]} range:NSMakeRange(0, 1)];

    [attStr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:21]} range:NSMakeRange(1, text.length-1)];
    textField.attributedText = attStr;

    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        
        NSString *money = [textField.text substringFromIndex:2];
        [self confirmMoneyWithMoney:money];
        
        return YES;
    }else {
        [MBProgressHUD showHUDWithMessage:@"请输入金额"];
        return NO;
    }
}

- (void)confirmMoneyWithMoney:(NSString *)money {
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] updatePropertyInfoWithOrderId:self.orderID status:@"TO_PAYING" doorTime:nil payValue:money result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD showHUDWithMessage:@"提交金额成功"];
            if (self.successBlock) {
                self.successBlock();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else {
            [MBProgressHUD showHUDWithMessage:@"提交失败"];
        }
    }];
}

- (IBAction)pay:(id)sender {
    
    if (_myTextField.text.length > 0) {
        
        NSString *money = [_myTextField.text substringFromIndex:2];
        [self confirmMoneyWithMoney:money];
        
    }else {
        [MBProgressHUD showHUDWithMessage:@"请输入金额"];
    }
    
}

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
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
