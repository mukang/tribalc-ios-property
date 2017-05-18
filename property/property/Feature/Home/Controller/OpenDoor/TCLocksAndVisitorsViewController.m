//
//  TCLocksAndVisitorsViewController.m
//  individual
//
//  Created by 王帅锋 on 17/3/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLocksAndVisitorsViewController.h"
#import "TCLockQRCodeViewController.h"
#import "TCAddVisitorViewController.h"

#import <TCCommonLibs/UIImage+Category.h>
#import <TCCommonLibs/TCCommonButton.h>

#import "TCVisitorLocksCell.h"
#import "TCLockOrVisitorSectionHeader.h"
#import "TCBuluoApi.h"
#import "TCMyLockQRCodeController.h"
#import "TCLockEquipViewCell.h"

#define kTCLocksCellID @"TCLocksCell"
#define kTCVisitorLockCellID @"TCVisitorLocksCell"
#define kTCVisitorLockSectionHeaderID @"TCLockOrVisitorSectionHeader"

@interface TCLocksAndVisitorsViewController ()<UITableViewDelegate,UITableViewDataSource,TCVisitorLocksCellDelegate, TCLockEquipViewCellDelegate>

@property (assign, nonatomic) TCLocksOrVisitors locksOrVisitors;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) UIView *noVisitorView;

@property (strong, nonatomic) UIButton *addBtn;

@property (strong, nonatomic) UIImageView *btnImageView;

@property (strong, nonatomic) UILabel *btnLabel;

@property (strong, nonatomic) TCCommonButton *generateButton;


@property (copy, nonatomic) NSArray *lockArr;
/** 锁设备id容器 */
@property (strong, nonatomic) NSMutableDictionary *lockEquipIDDic;

@end

@implementation TCLocksAndVisitorsViewController {
    __weak TCLocksAndVisitorsViewController *weakSelf;
}

- (instancetype)initWithType:(TCLocksOrVisitors)locksOrVisitors {
    if (self = [super init]) {
        weakSelf = self;
        _locksOrVisitors = locksOrVisitors;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    [self setupNavBar];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)setupNavBar {
    self.hideOriginalNavBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
    [navBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    [self.view addSubview:navBar];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"选择门锁"];
    navBar.titleTextAttributes = @{
                                        NSFontAttributeName : [UIFont systemFontOfSize:16],
                                        NSForegroundColorAttributeName : TCBlackColor
                                        };
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item_black"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(pop)];
    navItem.leftBarButtonItem = leftItem;
    [navBar setTintColor:TCBlackColor];
    [navBar setBackgroundImage:[UIImage imageWithColor:TCARGBColor(42, 42, 42, 0.0)] forBarMetrics:UIBarMetricsDefault];
    [navBar setItems:@[navItem]];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)loadData {
    if (self.locksOrVisitors == TCLocks) {
        [[TCBuluoApi api] fetchMyLockListResult:^(NSArray *lockList, NSError *error) {
            if ([lockList isKindOfClass:[NSArray class]]) {
                weakSelf.lockArr = lockList;
                [weakSelf.tableView reloadData];
                [weakSelf checkLocksOrVisitors];
            }else {
                NSString *reason = error.localizedDescription ?: @"请稍后再试";
                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取数据失败，%@", reason]];
            }
        }];
    }else {
        
        [[TCBuluoApi api] fetchVisitorMultiLockKeyList:^(NSArray *multiLockKeyList, NSError *error) {
            if ([multiLockKeyList isKindOfClass:[NSArray class]]) {
                weakSelf.lockArr = multiLockKeyList;
                [weakSelf.tableView reloadData];
                [weakSelf checkLocksOrVisitors];
            }else {
                NSString *reason = error.localizedDescription ?: @"请稍后再试";
                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取数据失败，%@", reason]];
            }
        }];
    }
}

- (void)setUpViews {
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addBtn];
    [self.addBtn addSubview:self.btnImageView];
    [self.addBtn addSubview:self.btnLabel];
    [self.view addSubview:self.generateButton];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(TCRealValue(40)));
        make.height.equalTo(@(TCRealValue(60)));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.addBtn.mas_top).offset(-10);
        make.height.equalTo(@(TCRealValue(260)));
    }];
    
    [self.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addBtn);
        make.top.equalTo(self.addBtn).offset(10);
        make.width.height.equalTo(@(TCRealValue(30)));
    }];
    
    [self.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addBtn);
        make.top.equalTo(self.btnImageView.mas_bottom).offset(5);
    }];
    
    [self.generateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(49);
    }];
}

- (void)checkLocksOrVisitors {
    if (self.lockArr.count) {
        if (self.noVisitorView) {
            [self.noVisitorView removeFromSuperview];
            self.noVisitorView = nil;
        }
    } else {
        if (!self.noVisitorView) {
            NSString *title;
            if (self.locksOrVisitors == TCLocks) {
                title = @"您的公司未被授权，暂不支持开锁";
            } else {
                title = @"您还没有添加访客，请您添加访客";
            }
            [self addNoVisitorViewWithTitle:title];
        }
    }
}

- (void)addNoVisitorViewWithTitle:(NSString *)title {
    UIView *noVisitorView = [[UIView alloc] init];
    noVisitorView.backgroundColor = [UIColor whiteColor];
    noVisitorView.layer.cornerRadius = 5.0;
    noVisitorView.layer.borderColor = TCLightGrayColor.CGColor;
    CGFloat scale = TCScreenWidth > 375.0 ? 3 : 2;
    noVisitorView.layer.borderWidth = 1 / scale;
    noVisitorView.clipsToBounds = YES;
    [self.view insertSubview:noVisitorView aboveSubview:self.tableView];
    self.noVisitorView = noVisitorView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_no_visitors"]];
    [noVisitorView addSubview:imageView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = TCGrayColor;
    titleLabel.font = [UIFont systemFontOfSize:12];
    [noVisitorView addSubview:titleLabel];
    
    [noVisitorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.tableView);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(TCRealValue(59.5), TCRealValue(66.5)));
        make.top.equalTo(noVisitorView.mas_top).offset(TCRealValue(68));
        make.centerX.equalTo(noVisitorView);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.centerX.equalTo(imageView);
    }];
}

#pragma mark TCVisitorLocksCellDelegate
- (void)deleteEquip:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        TCMultiLockKey *multiLockKey = self.lockArr[indexPath.section];
        @WeakObj(self)
        [[TCBuluoApi api] deleteMultiLockKeyWithID:multiLockKey.ID result:^(BOOL success, NSError *error) {
            @StrongObj(self)
            if (success) {
                NSMutableArray *mutabelA = [NSMutableArray arrayWithArray:self.lockArr];
                [mutabelA removeObject:multiLockKey];
                self.lockArr = mutabelA;
                [self.tableView reloadData];
                [self checkLocksOrVisitors];
            }else {
                NSString *reason = error.localizedDescription ?: @"请稍后再试";
                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"删除失败，%@", reason]];
            }
        }];
    }
}

#pragma mark - TCLockEquipViewCellDelegate

- (void)lockEquipViewCell:(TCLockEquipViewCell *)cell didSelectedLockEquip:(TCLockEquip *)lockEquip {
    if (lockEquip.isMarked) { // 需要取消标记
        lockEquip.marked = NO;
        [self.lockEquipIDDic removeObjectForKey:lockEquip.ID];
    } else { // 需要添加标记
        if (self.lockEquipIDDic.count >= 4) {
            [MBProgressHUD showHUDWithMessage:@"最多可选4个门锁设备"];
            return;
        }
        lockEquip.marked = YES;
        [self.lockEquipIDDic setObject:lockEquip.ID forKey:lockEquip.ID];
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lockArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.locksOrVisitors == TCLocks) {
        TCLockEquipViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTCLocksCellID forIndexPath:indexPath];
        cell.lockEquip = self.lockArr[indexPath.row];
        cell.delegate = self;
        return cell;
    }else {
        TCVisitorLocksCell *cell = [tableView dequeueReusableCellWithIdentifier:kTCVisitorLockCellID];
        cell.imageView.image = [UIImage imageNamed:@"locks"];
        cell.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TCMultiLockKey *lockKey = self.lockArr[indexPath.section];
        cell.textLabel.text = lockKey.name;
        return cell;
    }
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.locksOrVisitors == TCVisitors) {
        TCMultiLockKey *key = self.lockArr[indexPath.section];
        TCLockQRCodeViewController *vc = [[TCLockQRCodeViewController alloc] initWithLockQRCodeType:TCLockQRCodeTypeVisitor];
        vc.lockKey = key;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSArray *)lockArr {
    if (_lockArr == nil) {
        _lockArr = [[NSArray alloc] init];
    }
    return _lockArr;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        if (self.locksOrVisitors == TCLocks) {
            _imageView.image = [UIImage imageNamed:@"openDoorBg"];
        }else {
            _imageView.image = [UIImage imageNamed:@"visitor"];
        }
    }
    return _imageView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.cornerRadius = 5.0;
        _tableView.layer.borderColor = TCLightGrayColor.CGColor;
        CGFloat scale = TCScreenWidth > 375.0 ? 3 : 2;
        _tableView.layer.borderWidth = 1 / scale;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = 40.0;
        if (self.locksOrVisitors == TCLocks) {
            _tableView.sectionHeaderHeight = 0.0;
        }else {
            _tableView.sectionHeaderHeight = 40.0;
        }
        [_tableView registerClass:[TCLockEquipViewCell class] forCellReuseIdentifier:kTCLocksCellID];
        [_tableView registerClass:[TCVisitorLocksCell class] forCellReuseIdentifier:kTCVisitorLockCellID];
        [_tableView registerClass:[TCLockOrVisitorSectionHeader class] forHeaderFooterViewReuseIdentifier:kTCVisitorLockSectionHeaderID];
    }
    return _tableView;
}

- (UIButton *)addBtn {
    if (_addBtn == nil) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn addTarget:self action:@selector(handleClickAddButton:) forControlEvents:UIControlEventTouchUpInside];
        if (self.locksOrVisitors == TCLocks) {
            _addBtn.hidden = YES;
        }else {
            _addBtn.hidden = NO;
        }
    }
    return _addBtn;
}

- (UIImageView *)btnImageView {
    if (_btnImageView == nil) {
        _btnImageView = [[UIImageView alloc] init];
        _btnImageView.image = [UIImage imageNamed:@"addVisitor"];
    }
    return _btnImageView;
}

- (UILabel *)btnLabel {
    if (_btnLabel == nil) {
        _btnLabel = [[UILabel alloc] init];
        _btnLabel.font = [UIFont systemFontOfSize:12];
        _btnLabel.textColor = TCBlackColor;
        _btnLabel.textAlignment = NSTextAlignmentCenter;
        _btnLabel.text = @"添加";
    }
    return _btnLabel;
}

- (TCCommonButton *)generateButton {
    if (_generateButton == nil) {
        _generateButton = [TCCommonButton bottomButtonWithTitle:@"生成二维码"
                                                          color:TCCommonButtonColorBlue
                                                         target:self
                                                         action:@selector(handleClickGenerateButton:)];
        if (self.locksOrVisitors == TCLocks) {
            _generateButton.hidden = NO;
        }else {
            _generateButton.hidden = YES;
        }
    }
    return _generateButton;
}

- (NSMutableDictionary *)lockEquipIDDic {
    if (_lockEquipIDDic == nil) {
        _lockEquipIDDic = [NSMutableDictionary dictionary];
    }
    return _lockEquipIDDic;
}

- (void)handleClickAddButton:(UIButton *)sender {
    TCAddVisitorViewController *vc = [[TCAddVisitorViewController alloc] init];
    vc.fromController = self;
    vc.addVisitorCompletion = ^() {
        [weakSelf loadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleClickGenerateButton:(TCCommonButton *)sender {
    if (self.lockEquipIDDic.count == 0) {
        [MBProgressHUD showHUDWithMessage:@"请选择门锁设备"];
        return;
    }
    TCMyLockQRCodeController *vc = [[TCMyLockQRCodeController alloc] initWithLockQRCodeType:TCQRCodeTypeCustom];
    vc.equipIDs = self.lockEquipIDDic.allKeys;
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
