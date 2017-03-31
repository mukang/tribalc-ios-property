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
#import "TCVisitorLocksCell.h"
#import "TCLockOrVisitorSectionHeader.h"
#import "TCBuluoApi.h"

#define kTCLocksCellID @"TCLocksCell"
#define kTCVisitorLockCellID @"TCVisitorLocksCell"
#define kTCVisitorLockSectionHeaderID @"TCLockOrVisitorSectionHeader"

@interface TCLocksAndVisitorsViewController ()<UITableViewDelegate,UITableViewDataSource,TCVisitorLocksCellDelegate>

@property (assign, nonatomic) TCLocksOrVisitors locksOrVisitors;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) UIView *noVisitorView;

@property (strong, nonatomic) UIButton *addBtn;

@property (strong, nonatomic) UIImageView *btnImageView;

@property (strong, nonatomic) UILabel *btnLabel;

@property (copy, nonatomic) NSArray *lockArr;

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
        [[TCBuluoApi api] fetchMyLockKeysResult:^(NSArray *lockKeysList, NSError *error) {
            if ([lockKeysList isKindOfClass:[NSArray class]]) {
                weakSelf.lockArr = lockKeysList;
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
        
        TCLockWrapper *lockWrapper = self.lockArr[indexPath.section];
        
        NSArray *arr = lockWrapper.keys;
        
        if ([arr isKindOfClass:[NSArray class]]) {
            TCLockKey *lockKey = arr[indexPath.row];
            
            [[TCBuluoApi api] deleteLockKeyWithID:lockKey.ID result:^(BOOL success, NSError *error) {
                if (success) {
                    
                    if (arr.count == 1) {
                        
                        NSMutableArray *mutabelA = [NSMutableArray arrayWithArray:self.lockArr];
                        [mutabelA removeObject:lockWrapper];
                        self.lockArr = mutabelA;
                        
                    }else {
                        NSMutableArray *mutableArr = [NSMutableArray arrayWithArray:lockWrapper.keys];
                        [mutableArr removeObjectAtIndex:indexPath.row];
                        lockWrapper.keys = mutableArr;
                    }
                    [self.tableView reloadData];
                    [weakSelf checkLocksOrVisitors];
                }
            }];
        }
        
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.locksOrVisitors == TCLocks) {
        return 1;
    }
    return self.lockArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.locksOrVisitors == TCLocks) {
        return self.lockArr.count;
    }
    
    TCLockWrapper *lockWrapper = self.lockArr[section];
    if ([lockWrapper.keys isKindOfClass:[NSArray class]]) {
        return lockWrapper.keys.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.locksOrVisitors == TCLocks) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTCLocksCellID];
        cell.imageView.image = [UIImage imageNamed:@"locks"];
        
        TCLockEquip *lockE = self.lockArr[indexPath.row];
        cell.textLabel.text = lockE.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        
        TCVisitorLocksCell *cell = [tableView dequeueReusableCellWithIdentifier:kTCVisitorLockCellID];
        cell.imageView.image = [UIImage imageNamed:@"locks"];
        cell.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TCLockWrapper *wrapper = self.lockArr[indexPath.section];
        if ([wrapper.keys isKindOfClass:[NSArray class]]) {
            TCLockKey *key = wrapper.keys[indexPath.row];
            cell.textLabel.text = key.equipName;
        }
        
        return cell;
    }
    
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TCLockWrapper *wrapper = self.lockArr[section];
    
    TCLockOrVisitorSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTCVisitorLockSectionHeaderID];
    header.name = wrapper.name;
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCLockQRCodeViewController *vc;
    if (self.locksOrVisitors == TCLocks) {
        TCLockEquip *lockEquip = self.lockArr[indexPath.row];
        vc = [[TCLockQRCodeViewController alloc] initWithLockQRCodeType:TCLockQRCodeTypeOneself];
        vc.equipID = lockEquip.ID;
    } else {
        TCLockWrapper *wrapper = self.lockArr[indexPath.section];
        TCLockKey *key = wrapper.keys[indexPath.row];
        vc = [[TCLockQRCodeViewController alloc] initWithLockQRCodeType:TCLockQRCodeTypeVisitor];
        vc.lockKey = key;
    }
    [self.navigationController pushViewController:vc animated:YES];
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
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTCLocksCellID];
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

- (void)handleClickAddButton:(UIButton *)sender {
    TCAddVisitorViewController *vc = [[TCAddVisitorViewController alloc] init];
    vc.fromController = self;
    vc.addVisitorCompletion = ^() {
        [weakSelf loadData];
    };
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
