//
//  TCProfileViewController.m
//  individual
//
//  Created by 穆康 on 2016/10/26.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCProfileViewController.h"
#import "TCLoginViewController.h"
#import "TCBiographyViewController.h"
#import "TCIDAuthViewController.h"
#import "TCIDAuthDetailViewController.h"
#import "TCCompanyViewController.h"
#import "TCCompanyApplyViewController.h"
#import "TCSettingViewController.h"
#import "TCPropertyManageListController.h"
#import "TCQRCodeViewController.h"

#import "TCProfileHeaderView.h"
#import "TCProfileViewCell.h"
#import "TCPhotoModeView.h"

#import "TCImageURLSynthesizer.h"
#import "TCPhotoPicker.h"
#import "TCBuluoApi.h"

#import "UIImage+Category.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TCProfileViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate,
TCProfileHeaderViewDelegate,
TCPhotoPickerDelegate,
TCPhotoModeViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) TCProfileHeaderView *headerView;
@property (copy, nonatomic) NSArray *fodderArray;
@property (strong, nonatomic) TCUserInfo *userInfo;

@property (nonatomic) BOOL needsLightContentStatusBar;

@property (nonatomic) CGFloat headerViewHeight;
@property (nonatomic) CGFloat topBarHeight;

@property (strong, nonatomic) TCPhotoPicker *photoPicker;

@end

@implementation TCProfileViewController {
    __weak TCProfileViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    weakSelf = self;
    self.headerViewHeight = 240.0;
    self.topBarHeight = 64.0;
    
    [self setupNavBar];
    [self setupSubviews];
    [self updateHeaderView];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (![[self.navigationController.childViewControllers lastObject] isEqual:self]) {
        [self restoreNavigationBar];
    } else {
        // TODO:
    }
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)setupNavBar {
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile_nav_QRcode_item"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(handleClickQRCodeButton:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile_nav_setting_item"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleClickSettingButton:)];
//    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile_nav_message_item"]
//                                                                    style:UIBarButtonItemStylePlain
//                                                                   target:self
//                                                                   action:@selector(handleClickMessageButton:)];
//    self.navigationItem.rightBarButtonItems = @[messageItem, settingItem];
    self.navigationItem.rightBarButtonItem = settingItem;
}

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 49, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    TCProfileHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TCProfileHeaderView" owner:nil options:nil] firstObject];
    headerView.delegate = self;
    tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    UINib *nib = [UINib nibWithNibName:@"TCProfileViewCell" bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forCellReuseIdentifier:@"TCProfileViewCell"];
}

- (void)updateHeaderView {
    if ([[TCBuluoApi api] needLogin]) {
        self.headerView.loginButton.hidden = NO;
        self.headerView.nickBgView.hidden = YES;
        [self.headerView.avatarImageView setImage:[UIImage imageNamed:@"profile_default_avatar_icon"]];
        [self.headerView.bgImageView setImage:[UIImage imageNamed:@"profile_default_cover"]];
    } else {
        self.headerView.loginButton.hidden = YES;
        self.headerView.nickBgView.hidden = NO;
        TCUserInfo *userInfo = [[TCBuluoApi api] currentUserSession].userInfo;
        self.headerView.nickLabel.text = userInfo.nickname;
        if (userInfo.picture) {
            UIImage *currentAvatarImage = self.headerView.avatarImageView.image;
            NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:userInfo.picture];
            [self.headerView.avatarImageView sd_setImageWithURL:URL placeholderImage:currentAvatarImage options:SDWebImageRetryFailed];
        } else {
            [self.headerView.avatarImageView setImage:[UIImage imageNamed:@"profile_default_avatar_icon"]];
        }
        
        if (userInfo.cover) {
            UIImage *currentBgImage = self.headerView.bgImageView.image;
            NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:userInfo.cover];
            [self.headerView.bgImageView sd_setImageWithURL:URL placeholderImage:currentBgImage options:SDWebImageRetryFailed];
        } else {
            [self.headerView.bgImageView setImage:[UIImage imageNamed:@"profile_default_cover"]];
        }
    }
}

#pragma mark - Navigation Bar

- (void)restoreNavigationBar {
    [self updateNavigationBarWithAlpha:1.0];
}

- (void)updateNavigationBar {
    if ([[self.navigationController.childViewControllers lastObject] isEqual:self]) {
        CGFloat offsetY = self.tableView.contentOffset.y;
        CGFloat alpha = offsetY / (self.headerViewHeight - self.topBarHeight);
        alpha = roundf(alpha * 100) / 100;
        if (alpha > 1.0) alpha = 1.0;
        if (alpha < 0.0) alpha = 0.0;
        [self updateNavigationBarWithAlpha:alpha];
    }
}

- (void)updateNavigationBarWithAlpha:(CGFloat)alpha {
    UIColor *tintColor = nil, *titleColor = nil;
    if (alpha < 1.0) {
        self.navigationController.navigationBar.translucent = YES;
    } else {
        self.navigationController.navigationBar.translucent = NO;
    }
    if (alpha > 0.7) {
        self.needsLightContentStatusBar = YES;
        tintColor = [UIColor whiteColor];
        titleColor = [UIColor whiteColor];
    } else {
        self.needsLightContentStatusBar = NO;
        tintColor = TCRGBColor(65, 65, 65);
        titleColor = [UIColor clearColor];
    }
    [self.navigationController.navigationBar setTintColor:tintColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName : [UIFont systemFontOfSize:16],
                                                                    NSForegroundColorAttributeName : titleColor
                                                                    };
    UIImage *bgImage = [UIImage imageWithColor:TCARGBColor(42, 42, 42, alpha)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Status Bar

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.needsLightContentStatusBar ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setNeedsLightContentStatusBar:(BOOL)needsLightContentStatusBar {
    BOOL statusBarNeedsUpdate = (needsLightContentStatusBar != _needsLightContentStatusBar);
    _needsLightContentStatusBar = needsLightContentStatusBar;
    if (statusBarNeedsUpdate) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fodderArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *temp = self.fodderArray[section];
    return temp.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *currentCell;
    
    TCProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCProfileViewCell" forIndexPath:indexPath];
    NSDictionary *fodder = self.fodderArray[indexPath.section][indexPath.row];
    cell.titleLabel.text = fodder[@"title"];
    cell.iconImageView.image = [UIImage imageNamed:fodder[@"icon"]];
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    currentCell = cell;
    return currentCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat height = 54;
    return 54.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 14;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self checkUserNeedLogin]) return;
    
    if (indexPath.row == 0) { // 身份认证
        [self handleDidSelectedIDAuthCell];
    } else if (indexPath.row == 1) { // 我的公司
        [self handleDidSelectedMyCompanyCell];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavigationBar];
}

#pragma mark - TCProfileHeaderViewDelegate

- (void)didTapBioInProfileHeaderView:(TCProfileHeaderView *)view {
    if ([[TCBuluoApi api] needLogin]) {
        [self showLoginViewController];
    } else {
        TCBiographyViewController *vc = [[TCBiographyViewController alloc] init];
        vc.bioEditBlock = ^() {
            [weakSelf updateHeaderView];
        };
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didClickCardButtonInProfileHeaderView:(TCProfileHeaderView *)view {
    TCLog(@"点击了名片按钮");
    [self btnClickUnifyTips];
//    if ([self checkUserNeedLogin]) return;
}

- (void)didClickCollectButtonInProfileHeaderView:(TCProfileHeaderView *)view {
    TCLog(@"点击了收藏按钮");
    [self btnClickUnifyTips];
//    if ([self checkUserNeedLogin]) return;
}

- (void)didClickGradeButtonInProfileHeaderView:(TCProfileHeaderView *)view {
    TCLog(@"点击了等级按钮");
    [self btnClickUnifyTips];
//    if ([self checkUserNeedLogin]) return;
}

- (void)didClickPhotographButtonInProfileHeaderView:(TCProfileHeaderView *)view {
    if ([self checkUserNeedLogin]) return;
    
    TCPhotoModeView *photoModeView = [[TCPhotoModeView alloc] initWithController:self];
    photoModeView.delegate = self;
    [photoModeView show];
}

#pragma mark - TCPhotoModeViewDelegate

- (void)didClickCameraButtonInPhotoModeView:(TCPhotoModeView *)view {
    [view dismiss];
    TCPhotoPicker *photoPicker = [[TCPhotoPicker alloc] initWithSourceController:self];
    photoPicker.delegate = self;
    [photoPicker showPhotoPikerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    self.photoPicker = photoPicker;
}

- (void)didClickAlbumButtonInPhotoModeView:(TCPhotoModeView *)view {
    [view dismiss];
    TCPhotoPicker *photoPicker = [[TCPhotoPicker alloc] initWithSourceController:self];
    photoPicker.delegate = self;
    [photoPicker showPhotoPikerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    self.photoPicker = photoPicker;
}

#pragma mark - TCPhotoPickerDelegate

- (void)photoPicker:(TCPhotoPicker *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [photoPicker dismissPhotoPicker];
    self.photoPicker = nil;
    
    UIImage *coverImage;
    if (info[UIImagePickerControllerEditedImage]) {
        coverImage = info[UIImagePickerControllerEditedImage];
    } else {
        coverImage = info[UIImagePickerControllerOriginalImage];
    }
    
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] uploadImage:coverImage progress:nil result:^(BOOL success, TCUploadInfo *uploadInfo, NSError *error) {
        if (success) {
            [weakSelf changeUserCoverWithName:uploadInfo.objectKey];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"保存失败，%@", reason]];
        }
    }];
}

- (void)photoPickerDidCancel:(TCPhotoPicker *)photoPicker {
    [photoPicker dismissPhotoPicker];
    self.photoPicker = nil;
}

#pragma mark - Show Login View Controller

- (BOOL)checkUserNeedLogin {
    if ([[TCBuluoApi api] needLogin]) {
        [self showLoginViewController];
    }
    return [[TCBuluoApi api] needLogin];
}

- (void)showLoginViewController {
    TCLoginViewController *vc = [[TCLoginViewController alloc] initWithNibName:@"TCLoginViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Notifications 

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogin:) name:TCBuluoApiNotificationUserDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogout:) name:TCBuluoApiNotificationUserDidLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoDidUpdate:) name:TCBuluoApiNotificationUserInfoDidUpdate object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)changeUserCoverWithName:(NSString *)name {
    NSString *imagePath = [TCImageURLSynthesizer synthesizeImagePathWithName:name source:kTCImageSourceOSS];
    [[TCBuluoApi api] changeUserCover:imagePath result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            [weakSelf updateHeaderView];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"保存失败，%@", reason]];
        }
    }];
}

- (void)handleClickQRCodeButton:(UIBarButtonItem *)sender {
    TCLog(@"点击了扫码按钮");
    if ([self checkUserNeedLogin]) return;
    TCQRCodeViewController *qrVc = [[TCQRCodeViewController alloc] init];
    qrVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:qrVc animated:YES];
}

- (void)handleClickSettingButton:(UIBarButtonItem *)sender {
    if ([self checkUserNeedLogin]) return;
    
    TCSettingViewController *vc = [[TCSettingViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)handleClickMessageButton:(UIBarButtonItem *)sender {
//    TCLog(@"点击了消息按钮");
//}

- (void)handleUserDidLogin:(id)sender {
    [self updateHeaderView];
}

- (void)handleUserDidLogout:(id)sender {
    [self updateHeaderView];
}

- (void)handleUserInfoDidUpdate:(id)sender {
    [self updateHeaderView];
}

- (void)handleDidSelectedMyCompanyCell {
    TCUserInfo *userInfo = [TCBuluoApi api].currentUserSession.userInfo;
    if (userInfo.companyID) {
        TCCompanyViewController *vc = [[TCCompanyViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        TCCompanyApplyViewController *vc = [[TCCompanyApplyViewController alloc] initWithCompanyApplyStatus:TCCompanyApplyStatusNotApply];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)handleDidSelectedIDAuthCell {
    TCUserInfo *userInfo = [TCBuluoApi api].currentUserSession.userInfo;
    UIViewController *currentVC;
    if ([userInfo.authorizedStatus isEqualToString:@"PROCESSING"]) {
        TCIDAuthDetailViewController *vc = [[TCIDAuthDetailViewController alloc] initWithIDAuthStatus:TCIDAuthStatusProcessing];
        currentVC = vc;
    } else if ([userInfo.authorizedStatus isEqualToString:@"SUCCESS"] || [userInfo.authorizedStatus isEqualToString:@"FAILURE"]) {
        TCIDAuthDetailViewController *vc = [[TCIDAuthDetailViewController alloc] initWithIDAuthStatus:TCIDAuthStatusFinished];
        currentVC = vc;
    } else {
        TCIDAuthViewController *vc = [[TCIDAuthViewController alloc] initWithNibName:@"TCIDAuthViewController" bundle:[NSBundle mainBundle]];
        currentVC = vc;
    }
    currentVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:currentVC animated:YES];
}


#pragma mark - Override Methods

- (NSArray *)fodderArray {
    if (_fodderArray == nil) {
        _fodderArray = @[@[@{@"title": @"身份认证", @"icon": @"profile_identity_icon"},
                           @{@"title": @"我的公司", @"icon": @"profile_company_icon"},]
                         ];
    }
    return _fodderArray;
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
