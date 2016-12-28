//
//  TCShoppingCartListTableViewCell.m
//  individual
//
//  Created by WYH on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCShoppingCartListTableViewCell.h"
#import "TCComponent.h"
#import "TCImageURLSynthesizer.h"
#import "TCComputeView.h"

@implementation TCShoppingCartListTableViewCell {
    UIButton *selectStandardBtn;
    TCComputeView *computeView;
}

+ (instancetype)cellForTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"shoppingCartCell";
    TCShoppingCartListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TCShoppingCartListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.indexPath = indexPath;
    return cell;
}

+ (instancetype)editCellForTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"editShoppingCartCell";
    TCShoppingCartListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TCShoppingCartListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    } else {
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[TCComputeView class]]) {
                [subview removeFromSuperview];
            }
        }
    }
    cell.indexPath = indexPath;
    return cell;

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        TCShoppingCartSelectButton *selectButton = [[TCShoppingCartSelectButton alloc] initWithFrame:CGRectNull];
        [selectButton addTarget:self action:@selector(touchSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectButton];
        self.selectBtn = selectButton;
        
        UIImageView *leftImageView = [self getLeftImageView];
        [self.contentView addSubview:leftImageView];
        self.leftImageView = leftImageView;
        
        UILabel *titleLab = [self getLabelWithFont:[UIFont fontWithName:BOLD_FONT size:TCRealValue(14)] AndTextColor:[UIColor blackColor]];
        [self.contentView addSubview:titleLab];
        self.titleLab = titleLab;
        
        UILabel *primaryLab = [self getLabelWithFont:[UIFont systemFontOfSize:TCRealValue(12)] AndTextColor:TCRGBColor(154, 154, 154)];
        [self.contentView addSubview:primaryLab];
        self.primaryStandardLab = primaryLab;
        
        UIButton *secondaryBtn = [self getSecondaryBtn];
        [self.contentView addSubview:secondaryBtn];
        self.secondaryStandardBtn = secondaryBtn;
        
        UILabel *priceLab = [self getLabelWithFont:[UIFont fontWithName:BOLD_FONT size:TCRealValue(14)] AndTextColor:TCRGBColor(42, 42, 42)];
        [self.contentView addSubview:priceLab];
        self.priceLab = priceLab;
        
        UILabel *amountLab = [self getLabelWithFont:[UIFont fontWithName:BOLD_FONT size:TCRealValue(12)] AndTextColor:TCRGBColor(154, 154, 154)];
        [self.contentView addSubview:amountLab];
        self.amountLab = amountLab;
        
        UIButton *standardButton = [[UIButton alloc] init];
        [standardButton addTarget:self action:@selector(touchSelectStandardButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:standardButton];
        selectStandardBtn = standardButton;
        

    }
    return self;
}




#pragma mark - Setup CartItem
- (void)setCartItem:(TCCartItem *)cartItem {
    _cartItem = cartItem;
    [self setupData];
    [self setupFrame];
}

- (void)setEditCartItem:(TCCartItem *)cartItem {
    _cartItem = cartItem;
    [self setupData];
    [self setupEditFrame];
}

#pragma mark - Setup Data
- (void)setupData {
    self.selectBtn.isSelected = _cartItem.select;
    [self.leftImageView sd_setImageWithURL:[TCImageURLSynthesizer synthesizeImageURLWithPath:_cartItem.goods.mainPicture]];
    self.titleLab.text = _cartItem.goods.name;
    self.primaryStandardLab.text = [self getPrimaryStr];
    [self.primaryStandardLab sizeToFit];
    [self.secondaryStandardBtn setTitle:[self getSecondary] forState:UIControlStateNormal];
    self.priceLab.text = [NSString stringWithFormat:@"￥%@", @([NSString stringWithFormat:@"%f", _cartItem.goods.salePrice].floatValue)];
    [self.priceLab sizeToFit];
    self.amountLab.text = [NSString stringWithFormat:@"X %li", (long)_cartItem.amount];
    [self.amountLab sizeToFit];
}

- (NSString *)getPrimaryStr{
    NSArray *standardArr = [self getStandardArr];
    if (standardArr.count != 0) {
        return [NSString stringWithFormat:@"%@ : %@", standardArr[0], standardArr[1]];
    } else {
        return @"";
    }
}

- (NSString *)getSecondary {
    NSArray *standardArr = [self getStandardArr];
    if (standardArr.count == 4) {
        return standardArr[3];
    }
    else {
        return @"";
    }
}

- (NSArray *)getStandardArr {
    if ([_cartItem.goods.standardSnapshot containsString:@"|"]) {
        NSArray *standardArray = [_cartItem.goods.standardSnapshot componentsSeparatedByString:@"|"];
        NSArray *primaryArr = [standardArray[0] componentsSeparatedByString:@":"];
        NSArray *secondaryArr = [standardArray[1] componentsSeparatedByString:@":"];
        return @[ primaryArr[0], primaryArr[1], secondaryArr[0], secondaryArr[1] ];
    } else if ([_cartItem.goods.standardSnapshot containsString:@":"]){
        NSArray *standardArry = [_cartItem.goods.standardSnapshot componentsSeparatedByString:@":"];
        return @[ standardArry[0], standardArry[1]];
    } else {
        return @[];
    }
}

#pragma mark - Setup Frame
- (void)setupFrame {
    self.selectBtn.frame = CGRectMake(0, 0, TCRealValue(56), TCRealValue(139));
    self.leftImageView.frame = CGRectMake(self.selectBtn.x + self.selectBtn.width, TCRealValue(139) / 2 - TCRealValue(94 / 2), TCRealValue(94), TCRealValue(94));
    self.titleLab.frame = CGRectMake(TCRealValue(13) + self.leftImageView.x + self.leftImageView.width, TCRealValue(22.5 + 9), TCScreenWidth - TCRealValue(13) - TCRealValue(20) - self.leftImageView.x - self.leftImageView.width, TCRealValue(14));
    self.primaryStandardLab.frame = CGRectMake(self.titleLab.x, self.titleLab.y + self.titleLab.height + TCRealValue(9), self.titleLab.width, TCRealValue(12));
    if ([_cartItem.goods.standardSnapshot containsString:@"|"]) {
        self.secondaryStandardBtn.frame = CGRectMake(self.titleLab.x, self.primaryStandardLab.y + self.primaryStandardLab.height + TCRealValue(17), TCRealValue(94 / 2), TCRealValue(46 / 2));
        self.amountLab.frame = CGRectMake(self.titleLab.x + TCRealValue(47) + TCRealValue(7), self.primaryStandardLab.y + self.primaryStandardLab.height + TCRealValue(15.5), self.amountLab.width, TCRealValue(27));
    } else {
        self.secondaryStandardBtn.frame = CGRectNull;
        self.amountLab.frame = CGRectMake(self.titleLab.x + TCRealValue(7), self.primaryStandardLab.y + self.primaryStandardLab.height + TCRealValue(15.5), self.amountLab.width, TCRealValue(27));
    }
    self.priceLab.frame = CGRectMake(TCScreenWidth - TCRealValue(20) - self.priceLab.width , self.primaryStandardLab.y + self.primaryStandardLab.height + TCRealValue(15.5) + TCRealValue(8), self.priceLab.width, TCRealValue(14));
}

- (void)setupEditFrame {
    [self setupFrame];
    self.priceLab.frame = CGRectMake(TCScreenWidth - TCRealValue(20) - self.priceLab.width, self.primaryStandardLab.y - TCRealValue(3), self.priceLab.width, self.priceLab.height);
    
    
    computeView = [[TCComputeView alloc] initWithFrame:CGRectMake(self.width - TCRealValue(20) - TCRealValue(78), self.amountLab.y + (self.amountLab.height / 2 - TCRealValue(10)), TCRealValue(78), TCRealValue(20))];
    [computeView setCount:_cartItem.amount];
    computeView.x = TCScreenWidth - TCRealValue(20) - computeView.width;
    [computeView.addBtn addTarget:self action:@selector(touchAddBtn:) forControlEvents:UIControlEventTouchUpInside];
    [computeView.subBtn addTarget:self action:@selector(touchSubBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:computeView];
    
    selectStandardBtn.frame = CGRectMake(self.titleLab.x, self.primaryStandardLab.y, computeView.x - self.titleLab.x - TCRealValue(7), computeView.y + computeView.height - self.primaryStandardLab.y);
    self.amountLab.frame = CGRectNull;
}




#pragma mark - View
- (UIImageView *)getLeftImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.layer.borderWidth = TCRealValue(1);
    imageView.layer.borderColor = TCRGBColor(242, 242, 242).CGColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (UILabel *)getLabelWithFont:(UIFont *)font AndTextColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (UIButton *)getSecondaryBtn {
    UIButton *secondaryBtn = [[UIButton alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_second_button"]];
    imageView.size = CGSizeMake(TCRealValue(94 / 2), TCRealValue(46 / 2));
//    imageView.y = TCRealValue(23 * 0.038);
    [secondaryBtn addSubview:imageView];
    secondaryBtn.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    [secondaryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return secondaryBtn;
}


#pragma mark - Action
- (void)touchSelectButton:(TCShoppingCartSelectButton *)button {
    if (_shopCartDelegate && [_shopCartDelegate respondsToSelector:@selector(shoppingCartCell:didTouchSelectButtonWithIndexPath:)]) {
        [_shopCartDelegate shoppingCartCell:self didTouchSelectButtonWithIndexPath:self.indexPath];
    }
}

- (void)touchSelectStandardButton:(UIButton *)button {
    if (_shopCartDelegate && [_shopCartDelegate respondsToSelector:@selector(shoppingCartCell:didSelectSelectStandardWithCartItem:)]) {
        [_shopCartDelegate shoppingCartCell:self didSelectSelectStandardWithCartItem:_cartItem];
    }
}

- (void)touchAddBtn:(UIButton *)button {
    NSInteger addAmount = computeView.countLab.text.integerValue + 1;
    if (addAmount > _cartItem.repertory) {
        [MBProgressHUD showHUDWithMessage:@"超出库存量"];
    } else if(addAmount == 99) {
        
    } else{
        
        if (_shopCartDelegate && [_shopCartDelegate respondsToSelector:@selector(shoppingCartCell:AddOrSubAmountWithCartItem:)]) {
            _cartItem.amount = addAmount;
            [_shopCartDelegate shoppingCartCell:self AddOrSubAmountWithCartItem:_cartItem];
        }
    }
}

- (void)touchSubBtn:(UIButton *)button {
    NSInteger subAmount = computeView.countLab.text.integerValue - 1;
    if (subAmount == 0) {
        [MBProgressHUD showHUDWithMessage:@"不能再少了"];
    } else {
        
        if (_shopCartDelegate && [_shopCartDelegate respondsToSelector:@selector(shoppingCartCell:AddOrSubAmountWithCartItem:)]) {
            _cartItem.amount = subAmount;
            [_shopCartDelegate shoppingCartCell:self AddOrSubAmountWithCartItem:_cartItem];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
