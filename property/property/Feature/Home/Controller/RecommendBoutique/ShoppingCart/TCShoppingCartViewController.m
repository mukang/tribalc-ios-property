//
//  TCShoppingCartViewController.m
//  individual
//
//  Created by WYH on 16/11/5.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShoppingCartViewController.h"
#import "TCRecommendInfoViewController.h"
#import "TCShoppingCartBottom.h"

@interface TCShoppingCartViewController () {
    UITableView *cartTableView;
    UIButton *navRightBtn;
    TCShoppingCartBottom *cartBottomView;
    TCShoppingCartWrapper *shoppingCartWrapper;
    
    BOOL isEdit;
}

@end

@implementation TCShoppingCartViewController {
    __weak TCShoppingCartViewController *weakSelf;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!cartTableView) {
        [self initialTableView];
    } else {
        [cartTableView reloadData];
    }
    [self setupNavigationRightBarButton];

    [self initBottomView];
    
    weakSelf = self;
    [self initShoppingCartData];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isEdit = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"购物车";
    
    [self initialNavigationBar];
    
    [self setupBottomView];
}

#pragma mark - Init Data

- (void)initShoppingCartData {
    [MBProgressHUD showHUD:YES];
//    [[TCBuluoApi api] fetchShoppingCartWrapperWithSortSkip:nil result:^(TCShoppingCartWrapper *wrapper, NSError *error) {
//        if (wrapper) {
//            [MBProgressHUD hideHUD:YES];
//            shoppingCartWrapper = wrapper;
//            [cartTableView reloadData];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取购物车列表失败, %@", reason]];
//        }
//    }];
}

#pragma mark - Setup Bottom
- (void)setupBottomView {
    cartBottomView = [[TCShoppingCartBottom alloc] initWithFrame:CGRectMake(0, TCScreenHeight - 64 - TCRealValue(49), TCScreenWidth, TCRealValue(49))];
    [cartBottomView.deleteButton addTarget:self action:@selector(touchDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    [cartBottomView.payButton addTarget:self action:@selector(touchPayButton) forControlEvents:UIControlEventTouchUpInside];
    [cartBottomView.selectBtn addTarget:self action:@selector(touchSelectAllBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cartBottomView];
}

- (void)initBottomView {
    if (cartBottomView) {
        cartBottomView.selectBtn.isSelected = NO;
        cartBottomView.totalLab.text = @"￥0";
    }

}

#pragma mark - Setup NavigationBar

- (void)initialNavigationBar {
    self.title = @"购物车";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_item"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(touchBackBtn:)];

    
}


- (void)setupNavigationRightBarButton {
    UIButton *editBtn = [TCGetNavigationItem getBarButtonWithFrame:CGRectMake(0, 0, 40, 30) AndImageName:@""];
    [editBtn addTarget:self action:@selector(touchEditBar:) forControlEvents:UIControlEventTouchUpInside];
    if (isEdit) {
        [editBtn setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    editBtn.titleLabel.textColor = [UIColor whiteColor];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    
    self.navigationItem.rightBarButtonItem = editItem;
}


#pragma mark - Setup UI

- (void)initialTableView {
    cartTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64 - TCRealValue(49)) style:UITableViewStyleGrouped];
    cartTableView.backgroundColor  =[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    cartTableView.delegate = self;
    cartTableView.dataSource = self;
    cartTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cartTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:cartTableView];
}


- (UIView *)getStoreViewWithFrame:(CGRect)frame AndSection:(NSInteger)section{
    UIView *storeInfoView = [[UIView alloc] initWithFrame:frame];
    TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[section];
    TCMarkStore *storeInfo = listShoppingCart.store;
    storeInfoView.backgroundColor = [UIColor whiteColor];
    TCShoppingCartSelectButton *selectedBtn = [[TCShoppingCartSelectButton alloc] initWithFrame:CGRectMake(0, 0, TCRealValue(56), frame.size.height)];
    selectedBtn.isSelected = ![self judgeHasSelectedOrNotSelectedOrder:listShoppingCart.goodsList AndSelectedOrNotSelected:NO];
    selectedBtn.section = section;
    [selectedBtn addTarget:self action:@selector(touchSelectStoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    [storeInfoView addSubview:selectedBtn];
    UILabel *storeTitleLab = [TCComponent createLabelWithFrame:CGRectMake(selectedBtn.x + selectedBtn.width, 0, self.view.width - selectedBtn.x - selectedBtn.width - TCRealValue(20), storeInfoView.height) AndFontSize:TCRealValue(12) AndTitle:storeInfo.name AndTextColor:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1]];
    [storeInfoView addSubview:storeTitleLab];
    UIView *downLine = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), storeInfoView.height - TCRealValue(0.5), TCScreenWidth - TCRealValue(40), TCRealValue(0.5))];
    [storeInfoView addSubview:downLine];
    
    return storeInfoView;
}



- (void)setuptotalPriceLab {
    float price = 0;
    
    NSArray *contentArr = shoppingCartWrapper.content;
    for (int i = 0; i < contentArr.count; i++) {
        TCListShoppingCart *shoppingCart = contentArr[i];
        NSArray *goodList = shoppingCart.goodsList;
        for (int j = 0; j < goodList.count; j++) {
            TCCartItem *cartItem = goodList[j];
            if (cartItem.select) {
                TCGoods *good = cartItem.goods;
                price += good.salePrice * cartItem.amount;
            }
        }
    }
    cartBottomView.totalLab.text = [NSString stringWithFormat:@"￥%@", @([NSString stringWithFormat:@"%f", price].floatValue)];

}

#pragma mark - Setup GoodSelected

- (void)setupOrderItemSelected:(BOOL)select {
    NSArray *contentArr = shoppingCartWrapper.content;
    for (int i = 0; i < contentArr.count; i++) {
        TCListShoppingCart *shoppingCart = contentArr[i];
        NSArray *goodList = shoppingCart.goodsList;
        for (int j = 0; j < goodList.count; j++) {
            TCCartItem *cartItem = goodList[j];
            cartItem.select = select;
        }
    }
}

- (void)setupOrderItemSelected:(BOOL)select Section:(NSInteger)section {
    NSArray *contentArr = shoppingCartWrapper.content;
    TCListShoppingCart *shoppingCart = contentArr[section];
    NSArray *goodList = shoppingCart.goodsList;
    for (int i = 0; i < goodList.count; i++) {
        TCCartItem *cartItem = goodList[i];
        cartItem.select = select;
    }
}


# pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *contentArr = shoppingCartWrapper.content;
    return contentArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *contentArr = shoppingCartWrapper.content;
    TCListShoppingCart *listShoppingCart = contentArr[section];
    NSArray *goodsList = listShoppingCart.goodsList;
    return goodsList.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *identifier = @"headerCell";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
        headerView.frame = CGRectMake(0, 0, self.view.width, TCRealValue(39));
    }
    UIView *storeView = [self getStoreViewWithFrame:CGRectMake(0, TCRealValue(8), self.view.width, TCRealValue(39 - 8)) AndSection:section];
    [headerView addSubview:storeView];
    
    return headerView;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCShoppingCartListTableViewCell *cell;
    TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[indexPath.section];
    TCCartItem *cartItem = listShoppingCart.goodsList[indexPath.row];
    if (isEdit) {
        cell = [TCShoppingCartListTableViewCell editCellForTableView:tableView AndIndexPath:indexPath];
        [cell setEditCartItem:cartItem];
        
    } else {
        cell = [TCShoppingCartListTableViewCell cellForTableView:tableView AndIndexPath:indexPath];
        [cell setCartItem:cartItem];
        cell.delegate = self;
    }
    cell.shopCartDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

# pragma mark - TCShoppingCartListCellDelegate
- (void)shoppingCartCell:(TCShoppingCartListTableViewCell *)cell didTouchSelectButtonWithIndexPath:(NSIndexPath *)indexPath {
    
    TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[indexPath.section];
    TCCartItem *orderItem = listShoppingCart.goodsList[indexPath.row];
    orderItem.select = !orderItem.select;
    [self refreshTableViewWithSection:indexPath.section];
    [self setuptotalPriceLab];

}
- (void)shoppingCartCell:(TCShoppingCartListTableViewCell *)cell didSelectSelectStandardWithCartItem:(TCCartItem *)cartItem {
    TCSelectStandardView *standardView = [[TCSelectStandardView alloc] initWithCartItem:cartItem];
    standardView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:standardView];

}
- (void)shoppingCartCell:(TCShoppingCartListTableViewCell *)cell AddOrSubAmountWithCartItem:(TCCartItem *)cartItem {
    [self changeGoodStandardWithShoppingCartId:cartItem.ID newGoodId:cartItem.goods.ID amount:cartItem.amount];
}


# pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TCRealValue(139);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TCRealValue(39);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!isEdit) {
        TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[indexPath.section];
        TCCartItem *cartItem = listShoppingCart.goodsList[indexPath.row];
        TCRecommendInfoViewController *recommendInfoViewController = [[TCRecommendInfoViewController alloc] initWithGoodId:cartItem.goods.ID];
        [self.navigationController pushViewController:recommendInfoViewController animated:YES];
    }
}



#pragma mark - MGSwipeTableCellDelegate
- (NSArray<UIView *> *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    if (direction == MGSwipeDirectionRightToLeft) {
        TCShoppingCartListTableViewCell *selectCell = (TCShoppingCartListTableViewCell *)cell;
        return [weakSelf getCellLeftButtonWithSelectTag: selectCell.indexPath];
    }
    return nil;
}

- (NSArray *)getCellLeftButtonWithSelectTag:(NSIndexPath *)indexPath {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TCRealValue(150), TCRealValue(139))];
    TCShoppingCartSelectButton *editBtn = [weakSelf getSwipeDirectionRightToLeftButtonWithFrame:CGRectMake(0, 0, button.width, TCRealValue(139 / 2)) AndIndexPath:indexPath AndTitle:@"编辑"];
    [editBtn addTarget:weakSelf action:@selector(touchGoodEditBtn:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:editBtn];
    
    TCShoppingCartSelectButton *deleteBtn = [weakSelf getSwipeDirectionRightToLeftButtonWithFrame:CGRectMake(0, editBtn.y + editBtn.height, button.width, TCRealValue(139) / 2) AndIndexPath:indexPath AndTitle:@"删除"];
    [deleteBtn setBackgroundColor:[UIColor redColor]];
    [deleteBtn addTarget:weakSelf action:@selector(touchGoodDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:deleteBtn];
    
    return @[button];
}

- (TCShoppingCartSelectButton *)getSwipeDirectionRightToLeftButtonWithFrame:(CGRect)frame AndIndexPath:(NSIndexPath *)indexPath AndTitle:(NSString *)title{
    TCShoppingCartSelectButton *editBtn = [[TCShoppingCartSelectButton alloc] initWithFrame:frame];
    [editBtn setTitle:title forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editBtn setBackgroundColor:[UIColor lightGrayColor]];
    editBtn.section = indexPath.section;
    editBtn.row = indexPath.row;
    editBtn.hiddenSelectButton = YES;
    return editBtn;
}

#pragma mark - TCSelectStandardViewDelegate
- (void)selectStandardView:(TCSelectStandardView *)standardView didSelectConfirmButtonWithNumber:(NSInteger)number NewGoodsId:(NSString *)goodsId ShoppingCartGoodsId:(NSString *)shoppingCartGoodsId {
    [self changeGoodStandardWithShoppingCartId:shoppingCartGoodsId newGoodId:goodsId amount:number];
}



#pragma mark - Setup UITableViewCell

- (void)changeGoodStandardWithShoppingCartId:(NSString *)shoppingCartID newGoodId:(NSString *)newGoodId amount:(NSInteger)amount{
    [MBProgressHUD showHUD:YES];
//    [[TCBuluoApi api] changeShoppingCartWithShoppingCartGoodsId:shoppingCartID AndNewGoodsId:newGoodId AndAmount:amount result:^(TCCartItem *result, NSError *error) {
//        if (result) {
//            [MBProgressHUD hideHUD:YES];
//            [self initShoppingCartData];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"修改购物车商品失败, %@", reason]];
//        }
//    }];
}



#pragma mark - Get SelectedInfo

- (TCCartItem *)getOrderItemWithSection:(NSInteger)section AndRow:(NSInteger)row {
    TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[section];
    TCCartItem *orderItem = listShoppingCart.goodsList[row];
    return orderItem;
}



- (NSMutableArray *)getSelectedGoodsInfo {
    NSMutableArray *selectArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < shoppingCartWrapper.content.count; i++) {
        TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[i];
        for (int j = 0; j < listShoppingCart.goodsList.count; j++) {
            TCCartItem *orderItem = listShoppingCart.goodsList[j];
            if (orderItem.select) {
                [selectArr addObject:orderItem.ID];
            }
        }
    }
    
    return selectArr;
}



- (NSMutableArray *)getShoppingCartArrWithSelect:(BOOL)isSelect {
    NSMutableArray *selectArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < shoppingCartWrapper.content.count; i++) {
        TCListShoppingCart *listShoppingCart = [[TCListShoppingCart alloc] init];
        TCListShoppingCart *allListShoppingCart = shoppingCartWrapper.content[i];
        listShoppingCart.store = allListShoppingCart.store;
        listShoppingCart.ID = allListShoppingCart.ID;
        if ([self judgeHasSelectedOrNotSelectedOrder:allListShoppingCart.goodsList AndSelectedOrNotSelected:isSelect]) {
            NSMutableArray *goodList = [[NSMutableArray alloc] init];
            for (int j = 0; j < allListShoppingCart.goodsList.count; j++) {
                TCCartItem *cartItem = allListShoppingCart.goodsList[j];
                if (cartItem.select == isSelect) {
                    [goodList addObject:cartItem];
                }
            }
            listShoppingCart.goodsList = goodList;
            [selectArr addObject:listShoppingCart];
        }
    }
    return selectArr;

}

- (BOOL)judgeHasSelectedOrNotSelectedOrder:(NSArray *)goodList AndSelectedOrNotSelected:(BOOL)selected{
    for (int i = 0; i < goodList.count; i++) {
        TCCartItem *orderItem = goodList[i];
        if (orderItem.select == selected) {
            return YES;
        }
    }
    
    return NO;
}



# pragma mark - Click Action

- (void)touchBackBtn:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchDeleteButton {
    NSArray *goodsArr = [[NSArray alloc] initWithArray:[self getSelectedGoodsInfo]];
    if (goodsArr.count == 0) {
        [MBProgressHUD showHUDWithMessage:@"未选择需要删除的物品"];
        return;
    }
    [MBProgressHUD showHUD:YES];
//    [[TCBuluoApi api] deleteShoppingCartWithShoppingCartArr:goodsArr result:^(BOOL result, NSError *error) {
//        if (result) {
//            [MBProgressHUD hideHUD:YES];
//            shoppingCartWrapper.content = [weakSelf getShoppingCartArrWithSelect:NO];
//            [cartTableView reloadData];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"删除失败, %@", reason]];
//        }
//    }];
    
}

- (void)touchPayButton {
    
    NSArray *selectArr = [self getShoppingCartArrWithSelect:YES];
    if (selectArr.count != 0) {
        TCPlaceOrderViewController *placeOrderViewController = [[TCPlaceOrderViewController alloc] initWithListShoppingCartArr:selectArr];
        [self.navigationController pushViewController:placeOrderViewController animated:YES];
    } else {
        [MBProgressHUD showHUDWithMessage:@"您还未选择商品"];
    }
    
}


- (void)touchSelectStoreBtn:(TCShoppingCartSelectButton *)button {
    NSInteger section = button.section;
    button.isSelected = !button.isSelected;
    [self setupOrderItemSelected:button.isSelected Section:section];
    
    [self refreshTableViewWithSection:section];
    [self setuptotalPriceLab];
    
}

- (void)touchSelectAllBtn:(UIButton *)button {
    if (cartBottomView.selectBtn.isSelected) {
        cartBottomView.selectBtn.isSelected = NO;
        [self setupOrderItemSelected:NO];
    } else {
        cartBottomView.selectBtn.isSelected = YES;
        [self setupOrderItemSelected:YES];
    }
    
    [cartTableView reloadData];
    [self setuptotalPriceLab];
}

- (void)touchEditBar:(UIButton *)btn {
    isEdit = !isEdit;
    cartBottomView.isEdit = isEdit;
    cartBottomView.selectBtn.isSelected = NO;
    [self setupOrderItemSelected:NO];
    [cartTableView reloadData];
    [self setuptotalPriceLab];
    [self setupNavigationRightBarButton];
}


- (void)touchGoodEditBtn:(TCShoppingCartSelectButton *)button {
    NSInteger section = button.section;
    NSInteger row = button.row;
    TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[section];
    TCCartItem *orderItem = listShoppingCart.goodsList[row];
    TCSelectStandardView *standardView = [[TCSelectStandardView alloc] initWithCartItem:orderItem ];
    standardView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:standardView];
}

- (void)touchGoodDeleteBtn:(TCShoppingCartSelectButton *)button {
    
    NSInteger section = button.section;
    NSInteger row = button.row;
    TCListShoppingCart *listShoppingCart = shoppingCartWrapper.content[section];
    TCCartItem *orderItem = listShoppingCart.goodsList[row];
    orderItem.select = YES;
    [MBProgressHUD showHUD:YES];
//    [[TCBuluoApi api] deleteShoppingCartWithShoppingCartArr:@[ orderItem.ID ] result:^(BOOL result, NSError *error) {
//        if (result) {
//            [MBProgressHUD hideHUD:YES];
//            shoppingCartWrapper.content = [weakSelf getShoppingCartArrWithSelect:NO];
//            [cartTableView reloadData];
//        } else {
//            NSString *reason = error.localizedDescription ?: @"请稍后再试";
//            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"删除失败, %@", reason]];
//        }
//    }];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)refreshTableViewWithSection:(NSInteger)section {
    if ([self judgeIsSelectedAllOrderItem]) {
        cartBottomView.selectBtn.isSelected = YES;
        [cartTableView reloadData];
    } else {
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:section];
        [cartTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        
        if (cartBottomView.selectBtn.isSelected) {
            cartBottomView.selectBtn.isSelected = NO;
        }
    }
    
}


- (BOOL)judgeIsSelectedAllOrderItem {
    NSArray *contentArr = shoppingCartWrapper.content;
    for (int i = 0; i < contentArr.count; i++) {
        TCListShoppingCart *shoppingCart = contentArr[i];
        NSArray *goodList = shoppingCart.goodsList;
        for (int j = 0; j < goodList.count; j++) {
            TCCartItem *orderItem = goodList[j];
            if (!orderItem.select) {
                return false;
            }
        }
    }
    
    return true;
}


- (void)viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
    UIImageView *barImageView = self.navigationController.navigationBar.subviews.firstObject;
    barImageView.backgroundColor =[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
    barImageView.alpha = 1;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
