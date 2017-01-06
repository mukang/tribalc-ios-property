//
//  TCCompanyApplyViewController.m
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCCompanyApplyViewController.h"
#import "TCCompanyApplyDetailViewController.h"

#import "TCCommonButton.h"
#import "TCBuluoApi.h"

#import <Masonry.h>

@interface TCCompanyApplyViewController ()

@property (weak, nonatomic) UILabel *promptLabel;
@property (weak, nonatomic) TCCommonButton *actionButton;

@end

@implementation TCCompanyApplyViewController {
    __weak TCCompanyApplyViewController *weakSelf;
}

- (instancetype)initWithCompanyApplyStatus:(TCCompanyApplyStatus)applyStatus {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _applyStatus = applyStatus;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    weakSelf = self;
    
    [self setupNavBar];
    [self setupSubviews];
    [self setupConstraints];
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.navigationItem.title = @"我的公司";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *prompt;
    NSString *actionTitle;
    switch (self.applyStatus) {
        case TCCompanyApplyStatusNotApply:
            prompt = @"您还未绑定企业，请绑定";
            actionTitle = @"申请绑定";
            break;
        case TCCompanyApplyStatusProcess:
            prompt = @"您的申请已提交，请耐心等待";
            actionTitle = @"返回首页";
            break;
        case TCCompanyApplyStatusFailure:
            prompt = @"该公司拒绝了您的申请，请查看填写信息重新申请";
            actionTitle = @"重新申请";
            break;
            
        default:
            break;
    }
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.text = prompt;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.textColor = TCRGBColor(42, 42, 42);
    promptLabel.font = [UIFont systemFontOfSize:16];
    promptLabel.numberOfLines = 0;
    [self.view addSubview:promptLabel];
    self.promptLabel = promptLabel;
    
    TCCommonButton *actionButton = [TCCommonButton buttonWithTitle:actionTitle target:self action:@selector(handleClickActionButton:)];
    [self.view addSubview:actionButton];
    self.actionButton = actionButton;
}

- (void)setupConstraints {
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).with.offset(TCRealValue(267));
        make.left.equalTo(weakSelf.view.mas_left).with.offset(48);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-48);
    }];
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).with.offset(TCRealValue(321));
        make.left.equalTo(weakSelf.view.mas_left).with.offset(30);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-30);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    UIViewController *vc = self.navigationController.childViewControllers[0];
    [self.navigationController popToViewController:vc animated:YES];
}

- (void)handleClickActionButton:(TCCommonButton *)sender {
    switch (self.applyStatus) {
        case TCCompanyApplyStatusNotApply:
        case TCCompanyApplyStatusFailure:
            [self handlePushToApplyDetailVC];
            break;
        case TCCompanyApplyStatusProcess:
            [self handleClickBackButton:nil];
            break;
            
        default:
            break;
    }
}

- (void)handlePushToApplyDetailVC {
    TCUserInfo *userInfo = [TCBuluoApi api].currentUserSession.userInfo;
    if (![userInfo.authorizedStatus isEqualToString:@"SUCCESS"]) {
        [MBProgressHUD showHUDWithMessage:@"身份认证成功后才可绑定公司"];
        return;
    }
    
    TCCompanyApplyDetailViewController *vc = [[TCCompanyApplyDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
