//
//  TCOrderMainViewController.m
//  individual
//
//  Created by WYH on 16/11/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserOrderTabBarController.h"
#import "TCPlaceOrderViewController.h"
#import "TCShoppingCartViewController.h"

@interface TCUserOrderTabBarController () {
    UIView *selectUnderlineView;
    UIButton *allOrderBtn;
    UIButton *waitPayBtn;
    UIButton *waitTakeBtn;
    UIButton *completeBtn;
}

@end

@implementation TCUserOrderTabBarController


- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.title = title;
        [self selectIndexWithTitle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *selectTabBarView = [self getSelectTabBarViewWithFrame:CGRectMake(0, 0, self.view.width, TCRealValue(40.5))];
    [self.view addSubview:selectTabBarView];
    
    [self addChildController:[[TCUserOrderViewController alloc] initWithStatus:nil] AndTitle:@"全部"];
    [self addChildController:[self getControllerWithStatus:@"NO_SETTLE"] AndTitle:@"等代付款"];
    [self addChildController:[self getControllerWithStatus:@"DELIVERY"] AndTitle:@"等待收货"];
    [self addChildController:[self getControllerWithStatus:@"RECEIVED"] AndTitle:@"已完成"];
    self.selectedIndex = 0;
    
}

- (void)selectIndexWithTitle {
    if ([self.title isEqualToString:@"待付款"]) {
        [self touchOrderSelectBtn:waitPayBtn];
    } else if ([self.title isEqualToString:@"待收货"]) {
        [self touchOrderSelectBtn:waitTakeBtn];
    } else if ([self.title isEqualToString:@"已结束"]) {
        [self touchOrderSelectBtn:completeBtn];
    } else {
        [self touchOrderSelectBtn:allOrderBtn];
    }
}


- (void)addChildController:(UIViewController *)childController AndTitle:(NSString *)title {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:childController];
    [navigationController.navigationBar setHidden:YES];
    childController.title = title;
    [self addChildViewController:childController];
}

- (TCUserOrderViewController *)getControllerWithStatus:(NSString *)status {

    TCUserOrderViewController *userOrderController = [[TCUserOrderViewController alloc] initWithStatus:status];
    return userOrderController;
}


- (UIView *)getSelectTabBarViewWithFrame:(CGRect)frame {
    UIView *selectView = [[UIView alloc] initWithFrame:frame];
    selectView.backgroundColor = [UIColor whiteColor];
    
    CGFloat centerWidth = (TCScreenWidth - TCRealValue(154) - TCRealValue(40)) / 3;
    allOrderBtn = [self getSelectButtonWithFrame:CGRectMake(TCRealValue(20), 0, 0, frame.size.height) AndText:@"全部"];
    allOrderBtn.tag = 0;
    [selectView addSubview:allOrderBtn];
    selectUnderlineView = [TCComponent createGrayLineWithFrame:CGRectMake(allOrderBtn.x - TCRealValue(5), allOrderBtn.y + allOrderBtn.height - TCRealValue(1), allOrderBtn.width + TCRealValue(10.5), TCRealValue(1))];
    selectUnderlineView.backgroundColor = [UIColor colorWithRed:81/255.0 green:199/255.0 blue:209/255.0 alpha:1];
    
    waitPayBtn = [self getSelectButtonWithFrame:CGRectMake(allOrderBtn.origin.x + allOrderBtn.width + centerWidth, 0, 0, frame.size.height) AndText:@"待付款"];
    waitPayBtn.tag = 1;
    [selectView addSubview:waitPayBtn];
    waitTakeBtn = [self getSelectButtonWithFrame:CGRectMake(waitPayBtn.origin.x + waitPayBtn.width + centerWidth, 0, 0, allOrderBtn.height) AndText:@"待收货"];
    waitTakeBtn.tag = 2;
    [selectView addSubview:waitTakeBtn];
    completeBtn = [self getSelectButtonWithFrame:CGRectMake(waitTakeBtn.x + waitTakeBtn.width + centerWidth, 0, 0, allOrderBtn.height) AndText:@"已完成"];
    completeBtn.tag = 3;
    [selectView addSubview:completeBtn];
    
    [selectView addSubview:selectUnderlineView];
    
    return selectView;
}

- (UIButton *)getSelectButtonWithFrame:(CGRect)frame AndText:(NSString *)text{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:BOLD_FONT size:TCRealValue(14)];
    if ([text isEqualToString:@"全部"]) {
        [button setTitleColor:[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1] forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1] forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(touchOrderSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button setHeight:frame.size.height];
    return button;
}

- (void)touchOrderSelectBtn:(UIButton *)button {
    
    UIView *superView = button.superview;
    for (int i = 0; i < superView.subviews.count; i++) {
        if ([superView.subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *selectBtn = superView.subviews[i];
            [selectBtn setTitleColor:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
    
    [button setTitleColor:[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1] forState:UIControlStateNormal];
    [selectUnderlineView setFrame:CGRectMake(button.x - 5, button.y + button.height - 1, button.width + 10.5, 1)];
    self.selectedIndex = button.tag;
    self.title = @"我的订单";
    
}

- (void)initNavigationBar {
    self.title = @"我的订单";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(touchBackButton)];
}

- (void)touchBackButton {
    NSArray *navigationArr = self.navigationController.viewControllers;
    if ([navigationArr[navigationArr.count - 2] isKindOfClass:[TCPlaceOrderViewController class]]) {
        TCShoppingCartViewController *shoppingCartViewController = navigationArr[navigationArr.count - 3];
        [self.navigationController popToViewController:shoppingCartViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
