//
//  TCBiographyViewController.m
//  individual
//
//  Created by 穆康 on 2016/10/27.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBiographyViewController.h"
#import "TCBioEditPhoneViewController.h"
#import "TCBioEditNickViewController.h"
#import "TCBioEditGenderViewController.h"
#import "TCBioEditEmotionViewController.h"
#import "TCBioEditBirthdateViewController.h"

#import "TCBiographyViewCell.h"
#import "TCBiographyAvatarViewCell.h"
#import "TCPhotoModeView.h"

#import "UIImage+Category.h"
#import "MBProgressHUD+Category.h"

#import "TCBuluoApi.h"
#import "TCPhotoPicker.h"
#import "TCImageURLSynthesizer.h"

@interface TCBiographyViewController () <UITableViewDelegate, UITableViewDataSource, TCPhotoModeViewDelegate, TCPhotoPickerDelegate>

@property (copy, nonatomic) NSArray *biographyTitles;
@property (copy, nonatomic) NSArray *bioDetailsTitles;

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) TCPhotoPicker *photoPicker;

@end

@implementation TCBiographyViewController {
    __weak TCBiographyViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    weakSelf = self;
    
    [self setupNavBar];
    [self setupSubviews];
    [self fetchUserInfo];
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (void)setupNavBar {
    self.navigationItem.title = @"个人信息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleCickBackButton:)];
}

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.backgroundColor = TCRGBColor(243, 243, 243);
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UINib *nib = [UINib nibWithNibName:@"TCBiographyViewCell" bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forCellReuseIdentifier:@"TCBiographyViewCell"];
    nib = [UINib nibWithNibName:@"TCBiographyAvatarViewCell" bundle:[NSBundle mainBundle]];
    [tableView registerNib:nib forCellReuseIdentifier:@"TCBiographyAvatarViewCell"];
}

- (void)fetchUserInfo {
    TCUserInfo *userInfo = [[TCBuluoApi api] currentUserSession].userInfo;
    
    // 昵称
    NSString *nickname = userInfo.nickname ?: @"";
    // 性别
    NSString *genderStr = @"";
    switch (userInfo.gender) {
        case TCUserGenderMale:
            genderStr = @"男";
            break;
        case TCUserGenderFemale:
            genderStr = @"女";
            break;
        default:
            break;
    }
    // 出生日期
    NSString *birthDateStr = @"";
    if (userInfo.birthday) {
        NSDate *birthDate = [NSDate dateWithTimeIntervalSince1970:(userInfo.birthday / 1000)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy年MM月dd日";
        birthDateStr = [dateFormatter stringFromDate:birthDate];
    }
    // 情感状况
    NSString *emotionStateStr = @"";
    switch (userInfo.emotionState) {
        case TCUserEmotionStateMarried:
            emotionStateStr = @"已婚";
            break;
        case TCUserEmotionStateSingle:
            emotionStateStr = @"单身";
            break;
        case TCUserEmotionStateLove:
            emotionStateStr = @"热恋";
            break;
        default:
            break;
    }
    // 电话号码
    NSString *phone = userInfo.phone ?: @"";
    
    self.bioDetailsTitles = @[@[@"", nickname, genderStr, birthDateStr, emotionStateStr], @[phone]];
    [self.tableView reloadData];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *currentCell = nil;
    if (indexPath.section == 0 && indexPath.row == 0) {
        TCBiographyAvatarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCBiographyAvatarViewCell" forIndexPath:indexPath];
        cell.avatar = [[TCBuluoApi api] currentUserSession].userInfo.picture;
        currentCell = cell;
    } else {
        TCBiographyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCBiographyViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = self.biographyTitles[indexPath.section][indexPath.row];
        cell.detailLabel.text = self.bioDetailsTitles[indexPath.section][indexPath.row];
        currentCell = cell;
    }
    return currentCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 106.5;
    } else {
        return 45;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: // 头像
                [self handleSelectAvatarCell];
                break;
            case 1: // 昵称
                [self handleSelectNickCell];
                break;
            case 2: // 性别
                [self handleSelectGenderCell];
                break;
            case 3: // 出生日期
                [self handleSelectBirthdateCell];
                break;
            case 4: // 情感状况
                [self handleSelectEmotionCell];
                break;
                
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0: // 手机号
                [self handleSelectPhoneCell];
                break;
                
            default:
                break;
        }
    }
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
    
    UIImage *avatarImage;
    if (info[UIImagePickerControllerEditedImage]) {
        avatarImage = info[UIImagePickerControllerEditedImage];
    } else {
        avatarImage = info[UIImagePickerControllerOriginalImage];
    }
    
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] uploadImage:avatarImage progress:nil result:^(BOOL success, TCUploadInfo *uploadInfo, NSError *error) {
        if (success) {
            [weakSelf handleUserAvatarChangedWithName:uploadInfo.objectKey];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"头像上传失败，%@", reason]];
        }
    }];
}

- (void)photoPickerDidCancel:(TCPhotoPicker *)photoPicker {
    [photoPicker dismissPhotoPicker];
    self.photoPicker = nil;
}

#pragma mark - Actions

- (void)handleCickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleUserAvatarChangedWithName:(NSString *)name {
    NSString *imagePath = [TCImageURLSynthesizer synthesizeImagePathWithName:name source:kTCImageSourceOSS];
    [[TCBuluoApi api] changeUserAvatar:imagePath result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if (weakSelf.bioEditBlock) {
                weakSelf.bioEditBlock();
            }
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"头像上传失败，%@", reason]];
        }
    }];
}

- (void)handleSelectAvatarCell {
    TCPhotoModeView *photoModeView = [[TCPhotoModeView alloc] initWithController:self];
    photoModeView.delegate = self;
    [photoModeView show];
}

- (void)handleSelectNickCell {
    TCBioEditNickViewController *vc = [[TCBioEditNickViewController alloc] init];
    vc.nickname = [[TCBuluoApi api] currentUserSession].userInfo.nickname;
    vc.editNickBlock = ^(NSString *nickname) {
        [weakSelf fetchUserInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSelectGenderCell {
    if ([[[TCBuluoApi api] currentUserSession].userInfo.authorizedStatus isEqualToString:@"SUCCESS"]) {
        [MBProgressHUD showHUDWithMessage:@"身份认证成功后，不能再修改性别"];
        return;
    }
    if ([[[TCBuluoApi api] currentUserSession].userInfo.authorizedStatus isEqualToString:@"PROCESSING"]) {
        [MBProgressHUD showHUDWithMessage:@"身份认证审核中，不能修改性别"];
        return;
    }
    TCBioEditGenderViewController *vc = [[TCBioEditGenderViewController alloc] init];
    vc.gender = [[TCBuluoApi api] currentUserSession].userInfo.gender;
    vc.editGenderBlock = ^() {
        [weakSelf fetchUserInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSelectEmotionCell {
    TCBioEditEmotionViewController *vc = [[TCBioEditEmotionViewController alloc] init];
    vc.emotionState = [[TCBuluoApi api] currentUserSession].userInfo.emotionState;
    vc.editEmotionBlock = ^() {
        [weakSelf fetchUserInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSelectBirthdateCell {
    if ([[[TCBuluoApi api] currentUserSession].userInfo.authorizedStatus isEqualToString:@"SUCCESS"]) {
        [MBProgressHUD showHUDWithMessage:@"身份认证成功后，不能再修改出生日期"];
        return;
    }
    if ([[[TCBuluoApi api] currentUserSession].userInfo.authorizedStatus isEqualToString:@"PROCESSING"]) {
        [MBProgressHUD showHUDWithMessage:@"身份认证审核中，不能修改出生日期"];
        return;
    }
    TCBioEditBirthdateViewController *vc = [[TCBioEditBirthdateViewController alloc] init];
    NSInteger birthday = [[TCBuluoApi api] currentUserSession].userInfo.birthday;
    if (birthday) {
        vc.birthdate = [NSDate dateWithTimeIntervalSince1970:birthday / 1000];
    }
    vc.editBirthdateBlock = ^() {
        [weakSelf fetchUserInfo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSelectPhoneCell {
    TCBioEditPhoneViewController *editPhoneVC = [[TCBioEditPhoneViewController alloc] initWithNibName:@"TCBioEditPhoneViewController" bundle:[NSBundle mainBundle]];
    editPhoneVC.editPhoneBlock = ^(BOOL isEdit) {
        if (isEdit) {
            [weakSelf fetchUserInfo];
        }
    };
    [self.navigationController pushViewController:editPhoneVC animated:YES];
}

#pragma mark - Override Methods

- (NSArray *)biographyTitles {
    if (_biographyTitles == nil) {
        _biographyTitles = @[@[@"头像", @"昵称", @"性别", @"出生日期", @"情感状态"], @[@"手机号"]];
    }
    return _biographyTitles;
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
