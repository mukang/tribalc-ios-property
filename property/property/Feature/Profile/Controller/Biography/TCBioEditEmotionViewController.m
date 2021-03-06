//
//  TCBioEditEmotionViewController.m
//  individual
//
//  Created by 穆康 on 2016/12/16.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBioEditEmotionViewController.h"
#import "TCBioEditSelectViewCell.h"

@interface TCBioEditEmotionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;

@end

@implementation TCBioEditEmotionViewController {
    __weak TCBioEditEmotionViewController *weakSelf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    weakSelf = self;
    
    [self setupNavBar];
    [self setupSubviews];
    
    if (self.emotionState) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.emotionState - 1 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.navigationItem.title = @"情感状况";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(handleClickBackButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleClickSaveButton:)];
}

- (void)setupSubviews {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = TCBackgroundColor;
    tableView.separatorColor = TCSeparatorLineColor;
    tableView.rowHeight = 44;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TCBioEditSelectViewCell class] forCellReuseIdentifier:@"TCBioEditSelectViewCell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCBioEditSelectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCBioEditSelectViewCell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"已婚";
            break;
        case 1:
            cell.titleLabel.text = @"单身";
            break;
        case 2:
            cell.titleLabel.text = @"热恋";
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.emotionState = indexPath.row + 1;
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickSaveButton:(UIBarButtonItem *)sender {
    if (!self.emotionState) {
        [MBProgressHUD showHUDWithMessage:@"请您情感状况"];
        return;
    }
    
    [MBProgressHUD showHUD:YES];
    [[TCBuluoApi api] changeUserEmotionState:self.emotionState result:^(BOOL success, NSError *error) {
        if (success) {
            [MBProgressHUD hideHUD:YES];
            if (weakSelf.editEmotionBlock) {
                weakSelf.editEmotionBlock();
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"情感状况修改失败，%@", reason]];
        }
    }];
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
