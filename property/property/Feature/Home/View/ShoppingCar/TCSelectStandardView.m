//
//  TCSelectStandardView.m
//  individual
//
//  Created by WYH on 16/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCSelectStandardView.h"
#import "TCBuluoApi.h"
#import "TCImageURLSynthesizer.h"
#import "TCComponent.h"
#import "TCClientConfig.h"
#import "NSObject+TCModel.h"
#import "UIImage+Category.h"

@implementation TCSelectStandardView {
    
    TCCartItem *mCartItem;
    
    TCGoodStandards *mGoodStandards;
    UIImageView *titleImageView;
    UILabel *priceLab;
    UILabel *inventoryLab;
    
    UIView *primarySelectButtonView;
    UIView *secondarySelectBtnView;
    

}

- (instancetype)initWithCartItem:(TCCartItem *)cartItem{
    self = [super initWithFrame:CGRectMake(0, 0, TCScreenWidth, TCScreenHeight)];
//    mGood = cartItem.goods;
//    mRepertory = cartItem.repertory;
//    mShoppingCartGoodsId = cartItem.ID;
    mCartItem = cartItem;
    if (self) {
        [self fetchGoodStandardWithStandardId:cartItem.standardId];
    }
    return self;
}

- (void)fetchGoodStandardWithStandardId:(NSString *)standardId {
    __weak TCSelectStandardView *weakSelf = self;
    [[TCBuluoApi api] fetchGoodStandards:standardId result:^(TCGoodStandards *goodStandard, NSError *error) {
        mGoodStandards = goodStandard;
        if (goodStandard.descriptions.allKeys.count == 2 && [goodStandard.descriptions[@"secondary"] isEqual:[NSNull null]]) {
            mGoodStandards.descriptions = @{ @"primary":mGoodStandards.descriptions[@"primary"] };
        }
        [weakSelf initUIWithGoodStandard:goodStandard];
    }];
}

- (void)initUIWithGoodStandard:(TCGoodStandards *)goodStandard {
    
    UIView *standardView = [[UIView alloc] initWithFrame:CGRectMake(0, TCScreenHeight, TCScreenWidth, TCScreenHeight)];
    standardView.backgroundColor = [UIColor whiteColor];
    
    UIView *titleView = [self getTitleViewWithFrame:CGRectMake(0, 0, TCScreenWidth, TCRealValue(118))];
    [standardView addSubview:titleView];
    
    UIView *standardSelectView = [self getStandardSelectViewWithOrigin:CGPointMake(0, titleView.y + titleView.height) AndGoodStandard:goodStandard];
    [standardView addSubview:standardSelectView];
    
    UIView *selectNumberView = [self getSelectNumberViewWithFrame:CGRectMake(0, standardSelectView.y + standardSelectView.height, TCScreenWidth, TCRealValue(89))];
    if (goodStandard.description == nil) {
        selectNumberView.y = TCRealValue(118);
    }
    [standardView addSubview:selectNumberView];
    
    UIButton *confirmBtn = [self getBottomBtnWithFrame:CGRectMake(0, standardSelectView.y + standardSelectView.height + TCRealValue(89), TCScreenWidth, TCRealValue(49))];
    [standardView addSubview:confirmBtn];
    
    standardView.height = confirmBtn.y + confirmBtn.height;
    
    
    UIView *backView = [self createBlankViewWithFrame:CGRectMake(0, 0, TCScreenWidth, standardView.y)];
    [self addSubview:backView];
    [self addSubview:standardView];
    [self startShowStandardView:standardView];
    
}

- (void)startShowStandardView:(UIView *)standardView {
    [UIView animateWithDuration:0.2 animations:^(void) {
        standardView.y = TCScreenHeight - standardView.height;
    }];
}


- (UIView *)createBlankViewWithFrame:(CGRect)frame {
    UIView *blankView = [[UIView alloc] initWithFrame:frame];
    blankView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    UITapGestureRecognizer *hideSelectRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchHideSelect:)];
    [blankView addGestureRecognizer:hideSelectRecognizer];
    
    return blankView;
}


- (UIButton *)getBottomBtnWithFrame:(CGRect)frame {
    UIButton *bottomBtn = [[UIButton alloc] initWithFrame:frame];
    
    bottomBtn.backgroundColor = TCRGBColor(81, 199, 209);
    [bottomBtn setTitle:@"确 定" forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(touchConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return bottomBtn;
}

- (UIView *)getStandardSelectViewWithOrigin:(CGPoint)point AndGoodStandard:(TCGoodStandards *)goodStandard {
    UIView *standardView = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, TCScreenWidth, 0)];
    if (goodStandard.descriptions.allKeys.count == 0) {
        standardView.height = TCRealValue(194);
    } else {
        UIView *primaryView = [self getStandardPrimarySelectViewWithFrame:CGRectMake(0, 0, TCScreenWidth, 0) AndGoodStandard:goodStandard];
        [standardView addSubview:primaryView];
        standardView.height = primaryView.y + primaryView.height;

        if (goodStandard.descriptions.allKeys.count == 2) {
            UIView * secondaryView = [self getStandardSecondarySelectViewWithFrame:CGRectMake(0, primaryView.y + primaryView.height, TCScreenWidth, 0) AndGoodStandard:goodStandard];
            [standardView addSubview:secondaryView];
            standardView.height = secondaryView.y + secondaryView.height;
        }
    }
    
    return standardView;
}

- (UIView *)getTitleViewWithFrame:(CGRect)frame {
    UIView *titleView = [[UIView alloc] initWithFrame:frame];
    titleImageView = [self getTitleImageViewWithFrame:CGRectMake(TCRealValue(20), frame.size.height - TCRealValue(12) - TCRealValue(115), TCRealValue(115), TCRealValue(115))];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    [titleView addSubview:titleImageView];
    
    UIButton *closeBtn = [TCComponent createImageBtnWithFrame:CGRectMake(TCScreenWidth - TCRealValue(20) - TCRealValue(20), TCRealValue(15), TCRealValue(20), TCRealValue(20)) AndImageName:@"good_close"];
    [closeBtn addTarget:self action:@selector(touchCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeBtn];
    
    NSString *priceStr = [NSString stringWithFormat:@"￥%@", @([NSString stringWithFormat:@"%f", mCartItem.goods.salePrice].floatValue)];
    priceLab = [TCComponent createLabelWithFrame:CGRectMake(titleImageView.x + titleImageView.width + TCRealValue(12), TCRealValue(20), TCScreenWidth - titleImageView.x - TCRealValue(12) , TCRealValue(20)) AndFontSize:TCRealValue(20) AndTitle:priceStr AndTextColor:TCRGBColor(81, 199, 209)];
    [titleView addSubview:priceLab];
    
    inventoryLab = [TCComponent createLabelWithFrame:CGRectMake(priceLab.x, priceLab.y + priceLab.height + TCRealValue(10), priceLab.width, TCRealValue(12)) AndFontSize:TCRealValue(12) AndTitle:[NSString stringWithFormat:@"(剩余:%li件)", (long)mCartItem.repertory] AndTextColor:TCRGBColor(154, 154, 154)];
    [titleView addSubview:inventoryLab];
    
    UILabel *selectTagLab = [TCComponent createLabelWithFrame:CGRectMake(priceLab.x, inventoryLab.y + inventoryLab.height + TCRealValue(12), TCRealValue(45), TCRealValue(14)) AndFontSize:TCRealValue(14) AndTitle:@"已选择" AndTextColor:TCRGBColor(42, 42, 42)];
    [titleView addSubview:selectTagLab];
    
    UIView *selectedView = [self getSelectedViewWithFrame:CGRectMake(selectTagLab.x + selectTagLab.width + TCRealValue(4), selectTagLab.y - TCRealValue(1), TCScreenWidth - selectTagLab.x - selectTagLab.width - TCRealValue(2), selectTagLab.height)];
    [titleView addSubview:selectedView];
    
    
    return titleView;
}


- (UIView *)getStandardSelectBaseViewWithFrame:(CGRect)frame AndGoodStandard:(TCGoodStandards *)goodStandards AndTitle:(NSString *)title {
    UIView *standardSelectView = [[UIView alloc] initWithFrame:frame];
    UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), 0, TCScreenWidth - TCRealValue(40), TCRealValue(1))];
    [standardSelectView addSubview:topLineView];
    
    UILabel *titleLab = [TCComponent createLabelWithFrame:CGRectMake(TCRealValue(20), TCRealValue(15), TCScreenWidth - TCRealValue(20), TCRealValue(14)) AndFontSize:TCRealValue(14) AndTitle:goodStandards.descriptions[@"primary"][@"label"]];
    titleLab.font = [UIFont fontWithName:BOLD_FONT size:TCRealValue(14)];
    [standardSelectView addSubview:titleLab];

    return standardSelectView;
}

- (UIView *)getStandardPrimarySelectViewWithFrame:(CGRect)frame AndGoodStandard:(TCGoodStandards *)goodStandards{
    UIView *primaryView = [self getStandardSelectBaseViewWithFrame:frame AndGoodStandard:goodStandards AndTitle:goodStandards.descriptions[@"primary"][@"label"]];
    
    primarySelectButtonView = [self getStandardPrimaryButtonViewWithFrame:CGRectMake(TCRealValue(20), TCRealValue(15 + 14 + 15), frame.size.width - TCRealValue(40), 0) AndGoodStandard:goodStandards];
    [primaryView addSubview:primarySelectButtonView];
    
    primaryView.height = primarySelectButtonView.y + primarySelectButtonView.height + TCRealValue(20);
    return primaryView;
}

- (UIView *)getStandardSecondarySelectViewWithFrame:(CGRect)frame AndGoodStandard:(TCGoodStandards *)goodStandards {
    UIView *secondaryView = [self getStandardSelectBaseViewWithFrame:frame AndGoodStandard:goodStandards AndTitle:goodStandards.descriptions[@"secondary"][@"label"]];
    
    secondarySelectBtnView = [self getStandardSecondaryButtonViewWithFrame:CGRectMake(TCRealValue(20), TCRealValue(15 + 14 + 15), frame.size.width - TCRealValue(40), 0) AndGoodStandard:goodStandards];
    [secondaryView addSubview:secondarySelectBtnView];
    
    secondaryView.height = secondarySelectBtnView.y + secondarySelectBtnView.height + TCRealValue(20);
    
    for (int i = 0; i < primarySelectButtonView.subviews.count; i++) {
        if ([primarySelectButtonView.subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *primaryBtn = primarySelectButtonView.subviews[i];
            if ([[primaryBtn titleForState:UIControlStateNormal] isEqualToString:_primaryStandardLab.text]) {
                [self setupPrimarySelectedButton:primaryBtn AndStandard:mGoodStandards];
            }
        }
    }
    
    return secondaryView;
}


- (UIView *)getStandardPrimaryButtonViewWithFrame:(CGRect)frame AndGoodStandard:(TCGoodStandards *)goodStandards {
    UIView *selectView = [[UIView alloc] initWithFrame:frame];
    CGFloat height = 0;
    CGFloat width = 0;
    NSArray *primaryArr = goodStandards.descriptions[@"primary"][@"types"];
    for (int i = 0; i < primaryArr.count; i++) {
        UIButton *selectButton = [self getPrimaryButtonWithOrigin:CGPointMake(width, height) AndTitle:primaryArr[i] AndGoodStandards:goodStandards];
        if (width > frame.size.width) {
            width = 0;
            height += TCRealValue(24 + 12);
            selectButton.origin = CGPointMake(width, height);
        }
        width += selectButton.width + TCRealValue(13);
        [selectView addSubview:selectButton];
        selectView.height = selectButton.y + selectButton.height;
    }
    
    return selectView;
}

- (UIView *)getStandardSecondaryButtonViewWithFrame:(CGRect)frame AndGoodStandard:(TCGoodStandards *)goodStandards {
    UIView *selectView = [[UIView alloc] initWithFrame:frame];
    CGFloat height = 0;
    CGFloat width = 0;
    NSArray *secondaryArr = goodStandards.descriptions[@"secondary"][@"types"];

    for (int i = 0; i < secondaryArr.count; i++) {
        UIButton *selectButton = [self getSecondaryButtonWithOrigin:CGPointMake(width, height) AndTitle:secondaryArr[i] AndGoodStandards:goodStandards];
        if (width + selectButton.width > frame.size.width) {
            width = 0;
            height += TCRealValue(22 + 12);
            selectButton.origin = CGPointMake(width, height);
        }
        width += selectButton.width + TCRealValue(11);
        [selectView addSubview:selectButton];
        selectView.height = selectButton.y + selectButton.height;;
    }
    
    return selectView;
}


- (UIButton *)getSecondaryButtonWithOrigin:(CGPoint)point AndTitle:(NSString *)title AndGoodStandards:(TCGoodStandards *)goodStandard{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(point.x, point.y, TCRealValue(47.5), TCRealValue(22))];
    button.layer.cornerRadius = TCRealValue(11);
    button.backgroundColor = TCRGBColor(242, 242, 242);
    [button setTitleColor:TCRGBColor(42, 42, 42) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    [button sizeToFit];
    [button addTarget:self action:@selector(touchSecondaryStandardBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (button.width > TCRealValue(47.5 - 14)) {
        button.size = CGSizeMake(button.width + TCRealValue(14), TCRealValue(22));
    } else {
        button.size = CGSizeMake(TCRealValue(47.5), TCRealValue(22));
    }
    NSString *secondaryStr = [mCartItem.goods.standardSnapshot containsString:@"|"] ? [mCartItem.goods.standardSnapshot componentsSeparatedByString:@"|"][1] : mCartItem.goods.standardSnapshot;
    NSString *secondaryType = [secondaryStr componentsSeparatedByString:@":"][1];
    if ([title isEqualToString:secondaryType]) {
        [self setupSecondarySelectedButton:button AndStandard:goodStandard];
    }
    
    return button;
}




- (UIButton *)getPrimaryButtonWithOrigin:(CGPoint)point AndTitle:(NSString *)title AndGoodStandards:(TCGoodStandards *)goodStandards{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(point.x, point.y, TCRealValue(51), TCRealValue(24))];
    button.layer.borderWidth = TCRealValue(1);
    button.layer.cornerRadius = TCRealValue(2.5);
    button.layer.borderColor = TCRGBColor(154, 154, 154).CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    [button setTitleColor:TCRGBColor(154, 154, 154) forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(touchPrimaryStandardBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (button.width > TCRealValue(51 - 14)) {
        button.size = CGSizeMake(button.width + TCRealValue(14), TCRealValue(24));
    } else {
        button.size = CGSizeMake(TCRealValue(51), TCRealValue(24));
    }
    NSString *type;
    TCGoods *mGood = mCartItem.goods;
    if ([mGood.standardSnapshot containsString:@"|"]) {
        type = [mGood.standardSnapshot componentsSeparatedByString:@"|"][0];
        type = [type componentsSeparatedByString:@":"][1];
    } else {
        type = [mGood.standardSnapshot componentsSeparatedByString:@":"][1];
    }
    if ([type isEqualToString:title]) {
        [self setupPrimarySelectedButton:button AndStandard:goodStandards];
    }
    return button;
    
}


- (UIView *)getSelectNumberViewWithFrame:(CGRect)frame {
    UIView *selectNumberView = [[UIView alloc] initWithFrame:frame];
    
    UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), 0, TCScreenWidth - TCRealValue(40), TCRealValue(1))];
    [selectNumberView addSubview:topLineView];
    
    UILabel *numberTagLab = [[UILabel alloc] initWithFrame:CGRectMake(TCRealValue(20), TCRealValue(29), TCRealValue(50), TCRealValue(14))];
    numberTagLab.text = @"数量";
    [selectNumberView addSubview:numberTagLab];
    
    UIButton *addBtn = [self createComputeBtnWithFrame:CGRectMake(frame.size.width - TCRealValue(20) - TCRealValue(38), frame.size.height / 2 - TCRealValue(38) / 5 * 3, TCRealValue(38), TCRealValue(35)) AndText:@"+"];
    [addBtn addTarget:self action:@selector(touchAddNumberBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectNumberView addSubview:addBtn];
    
    _numberLab = [self createBuyNumberLabelWithText:[NSString stringWithFormat:@"%ld", (long)mCartItem.amount] AndFrame:CGRectMake(addBtn.x - TCRealValue(58), addBtn.y, TCRealValue(58), addBtn.height)];
    [selectNumberView addSubview:_numberLab];
    
    UIButton *subBtn = [self createComputeBtnWithFrame:CGRectMake(_numberLab.x - TCRealValue(38), addBtn.y, TCRealValue(38), TCRealValue(35)) AndText:@"-"];
    [subBtn addTarget:self action:@selector(touchSubNumberBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectNumberView addSubview:subBtn];
    
    return selectNumberView;
}


- (UILabel *)createBuyNumberLabelWithText:(NSString *)text AndFrame:(CGRect)frame{
    UILabel *label = [TCComponent createLabelWithText:text AndFontSize:TCRealValue(16) AndTextColor:[UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1]];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFrame:frame];
    
    return label;
}



- (UIButton *)createComputeBtnWithFrame:(CGRect)frame AndText:(NSString *)text {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    [button setTitleColor:[UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1] forState:UIControlStateNormal];
    button.layer.cornerRadius = TCRealValue(3);
    button.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(16)];
    [button setTitle:text forState:UIControlStateNormal];
    return button;
}


- (void)setupPrimarySelectedButton:(UIButton *)button AndStandard:(TCGoodStandards *)goodStandards{

    [self setupPrimaryLabWithText:[button titleForState:UIControlStateNormal]];
    if (mGoodStandards.descriptions.allKeys.count == 2) {
        [self filterPrimaryButtonWithTitle:[button titleForState:UIControlStateNormal]];
    }
    for (int i = 0; i < button.superview.subviews.count; i++) {
        if ([button.superview.subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *noSelectBtn = button.superview.subviews[i];
            if (![[noSelectBtn titleColorForState:UIControlStateNormal] isEqual:TCRGBColor(221, 221, 221)]) {
                noSelectBtn.layer.borderColor = TCRGBColor(154, 154, 154).CGColor;
                [noSelectBtn setTitleColor:TCRGBColor(154, 154, 154) forState:UIControlStateNormal];
            }
        }
    }
    [button setTitleColor:TCRGBColor(81, 199, 209) forState:UIControlStateNormal];
    button.layer.borderColor = TCRGBColor(81, 199, 209).CGColor;
}


- (void)setupSecondarySelectedButton:(UIButton *)button AndStandard:(TCGoodStandards *)goodStandards{
    [self setupSecondaryLabWithText:[button titleForState:UIControlStateNormal]];
    [self filterSecondaryButtonWithTitle:[button titleForState:UIControlStateNormal]];
    for (int i = 0; i < button.superview.subviews.count; i++) {
        if ([button.superview.subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *noSelectBtn = button.superview.subviews[i];
            if (![[noSelectBtn titleColorForState:UIControlStateNormal] isEqual:TCRGBColor(221, 221, 221)]) {
                noSelectBtn.backgroundColor = TCRGBColor(242, 242, 242);
                [noSelectBtn setTitleColor:TCRGBColor(42, 42, 42) forState:UIControlStateNormal];
            }
        }
    }
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = TCRGBColor(81, 199, 209);

}

- (void)filterPrimaryButtonWithTitle:(NSString *)title {
    for (int i = 0; i < secondarySelectBtnView.subviews.count; i++) {
        if ([secondarySelectBtnView.subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *secondaryBtn = secondarySelectBtnView.subviews[i];
            NSString *indexesStr = [NSString stringWithFormat:@"%@^%@", title, [secondaryBtn titleForState:UIControlStateNormal]];
            if (![self judgeButtonIsEffective:indexesStr AndGoodStandards:mGoodStandards]) {
                secondaryBtn.backgroundColor = TCRGBColor(242, 242, 242);
                [secondaryBtn setTitleColor:TCRGBColor(221, 221, 221) forState:UIControlStateNormal];
            } else {
                if ([[secondaryBtn titleForState:UIControlStateNormal] isEqualToString:_secondaryStandardLab.text]) {
                    secondaryBtn.backgroundColor = TCRGBColor(81, 199, 209);
                    [secondaryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                } else {
                    secondaryBtn.backgroundColor = TCRGBColor(242, 242, 242);
                    [secondaryBtn setTitleColor:TCRGBColor(42, 42, 42) forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)filterSecondaryButtonWithTitle:(NSString *)title {
    for (int i = 0; i < primarySelectButtonView.subviews.count; i++) {
        if ([primarySelectButtonView.subviews[i] isKindOfClass:[UIButton class]]) {
            UIButton *primaryBtn = primarySelectButtonView.subviews[i];
            NSString *indexesStr = [NSString stringWithFormat:@"%@^%@",  [primaryBtn titleForState:UIControlStateNormal], title];
            if (![self judgeButtonIsEffective:indexesStr AndGoodStandards:mGoodStandards]) {
                primaryBtn.layer.borderColor = TCRGBColor(221, 221, 221).CGColor;
                [primaryBtn setTitleColor:TCRGBColor(221, 221, 221) forState:UIControlStateNormal];
            } else {
                if ([[primaryBtn titleForState:UIControlStateNormal] isEqualToString:_primaryStandardLab.text]) {
                    primaryBtn.layer.borderColor = TCRGBColor(81, 199, 209).CGColor;
                    [primaryBtn setTitleColor:TCRGBColor(81, 199, 209) forState:UIControlStateNormal];
                } else {
                    primaryBtn.layer.borderColor = TCRGBColor(154, 154, 154).CGColor;
                    [primaryBtn setTitleColor:TCRGBColor(154, 154, 154) forState:UIControlStateNormal];
                }
            }
        }
    }
}


- (BOOL)judgeButtonIsEffective:(NSString *)title AndGoodStandards:(TCGoodStandards *)goodStandards {
    NSDictionary *goodsIndexes = goodStandards.goodsIndexes;
    for (int i = 0; i < goodsIndexes.allKeys.count; i++) {
        if ([title isEqualToString:goodsIndexes.allKeys[i]]) {
            return YES;
        };
    }
    
    return NO;
}

- (UIView *)getSelectedViewWithFrame:(CGRect)frame {
    UIView *selectedView = [[UILabel alloc] initWithFrame:frame];
    
    _primaryStandardLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
    _primaryStandardLab.font = [UIFont systemFontOfSize:TCRealValue(14)];
    _primaryStandardLab.textColor = TCRGBColor(81, 199, 209);
    [selectedView addSubview:_primaryStandardLab];
    
    _secondaryStandardLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
    _secondaryStandardLab.font = [UIFont systemFontOfSize:TCRealValue(14)];
    _secondaryStandardLab.textColor = _primaryStandardLab.textColor;
    [selectedView addSubview:_secondaryStandardLab];
    
    return selectedView;
}

- (void)setupPrimaryLabWithText:(NSString *)text {
    _primaryStandardLab.text = text;
    [_primaryStandardLab sizeToFit];
    
    _secondaryStandardLab.x = _primaryStandardLab.x + _primaryStandardLab.width + TCRealValue(3);
}

- (void)setupSecondaryLabWithText:(NSString *)text {
    _secondaryStandardLab.text = text;
    [_secondaryStandardLab sizeToFit];
}

- (NSString *)getSelectedStrWithStandardSnapshot:(NSString *)standardStr {
    
    if ([standardStr containsString:@":"]) {
        if ([standardStr containsString:@"|"]) {
            NSArray *standardArr = [standardStr componentsSeparatedByString:@"|"];
            NSArray *primaryArr = [standardArr[0] componentsSeparatedByString:@":"];
            NSArray *secondArr = [standardArr[1] componentsSeparatedByString:@":"];
            return [NSString stringWithFormat:@"%@ %@", primaryArr[1], secondArr[1]];
        } else {
            NSArray *primaryArr = [standardStr componentsSeparatedByString:@":"];
            return primaryArr[1];
        }
        
    } else {
        return @"";
    }
}


- (UIImageView *)getTitleImageViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.layer.borderWidth = TCRealValue(1.5);
    imageView.layer.borderColor = TCRGBColor(242, 242, 242).CGColor;
    imageView.layer.cornerRadius = TCRealValue(5);
    NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:mCartItem.goods.mainPicture];
    UIImage *placeholderImage = [UIImage placeholderImageWithSize:imageView.size];
    [imageView sd_setImageWithURL:URL placeholderImage:placeholderImage options:SDWebImageRetryFailed];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.layer.masksToBounds = YES;
    return imageView;
}

- (UIView *)getStandardSelectViewWithFrame:(CGRect)frame {
    UIView *selectStandardView = [[UIView alloc] initWithFrame:frame];
    
    return selectStandardView;
}


- (void)touchPrimaryStandardBtn:(UIButton *)button {
    if ([[button titleColorForState:UIControlStateNormal] isEqual:TCRGBColor(81, 199, 209)]) {
        [self touchPrimaryWhenIsSelected:button];
    } else {
        if (![[button titleColorForState:UIControlStateNormal] isEqual:TCRGBColor(221, 221, 221)]) {
            [self setupPrimarySelectedButton:button AndStandard:mGoodStandards];
            NSString *goodsIndexes;
            if (mGoodStandards.descriptions.allKeys.count == 2) {
                goodsIndexes = [NSString stringWithFormat:@"%@^%@", _primaryStandardLab.text, _secondaryStandardLab.text];
            } else {
                goodsIndexes = [NSString stringWithFormat:@"%@", _primaryStandardLab.text];
            }
            TCGoodDetail *goodDetail = [[TCGoodDetail alloc] initWithObjectDictionary:mGoodStandards.goodsIndexes[goodsIndexes]];
            mCartItem.goods = [self transGoodDetailToGoods:goodDetail];
            mCartItem.repertory = goodDetail.repertory;
            [self setupBaseInfoWithGoodDetailDic:goodDetail];
        }
    }
}

- (void)touchPrimaryWhenIsSelected:(UIButton *)button {
    [button setTitleColor:TCRGBColor(154, 154, 154) forState:UIControlStateNormal];
    button.layer.borderColor = TCRGBColor(154, 154, 154).CGColor;
    _primaryStandardLab.text = @"";
    for (int i = 0; i < secondarySelectBtnView.subviews.count; i++) {
        UIButton *btn = secondarySelectBtnView.subviews[i];
        if (![[btn titleColorForState:UIControlStateNormal] isEqual:[UIColor whiteColor]]) {
            btn.backgroundColor = TCRGBColor(242, 242, 242);
            [btn setTitleColor:TCRGBColor(42, 42, 42) forState:UIControlStateNormal];
        }
    }
}

- (void)touchSecondaryWhenIsSelected:(UIButton *)button {
    button.backgroundColor = TCRGBColor(242, 242, 242);
    [button setTitleColor:TCRGBColor(42, 42, 42) forState:UIControlStateNormal];
    _secondaryStandardLab.text = @"";
    for (int i = 0; i < primarySelectButtonView.subviews.count; i++) {
        UIButton *btn = primarySelectButtonView.subviews[i];
        if (![[btn titleColorForState:UIControlStateNormal] isEqual:TCRGBColor(81, 199, 209)]) {
            [btn setTitleColor:TCRGBColor(154, 154, 154) forState:UIControlStateNormal];
            btn.layer.borderColor = TCRGBColor(154, 154, 154).CGColor;
        }
    }
}

- (TCGoods *)transGoodDetailToGoods:(TCGoodDetail *)goodDetail {
    TCGoods *good = [[TCGoods alloc] init];
    good.ID = goodDetail.ID;
    good.storeId = goodDetail.storeId;
    good.name = goodDetail.name;
    good.brand = goodDetail.brand;
    good.mainPicture = goodDetail.mainPicture;
    good.originPrice = goodDetail.originPrice;
    good.salePrice = goodDetail.salePrice;
    good.saleQuantity = goodDetail.saleQuantity;
    good.standardSnapshot = goodDetail.standardSnapshot;
    return good;
}

- (void)touchSecondaryStandardBtn:(UIButton *)button {
    if ([[button titleColorForState:UIControlStateNormal] isEqual:[UIColor whiteColor]]) {
        [self touchSecondaryWhenIsSelected:button];
    } else {
        if (![[button titleColorForState:UIControlStateNormal] isEqual:TCRGBColor(221, 221, 221)]) {
            [self setupSecondarySelectedButton:button AndStandard:mGoodStandards];
            NSString *goodsIndexes = [NSString stringWithFormat:@"%@^%@", _primaryStandardLab.text, _secondaryStandardLab.text];
            TCGoodDetail *goodDetail = [[TCGoodDetail alloc] initWithObjectDictionary:mGoodStandards.goodsIndexes[goodsIndexes]];
            mCartItem.goods = [self transGoodDetailToGoods:goodDetail];
            mCartItem.repertory = goodDetail.repertory;
            [self setupBaseInfoWithGoodDetailDic:goodDetail];
        }
    }
}

- (void)setupBaseInfoWithGoodDetailDic:(TCGoodDetail *)goodDetail {
    priceLab.text = [NSString stringWithFormat:@"￥%@", @([NSString stringWithFormat:@"%f", goodDetail.salePrice].floatValue)];
    inventoryLab.text = [NSString stringWithFormat:@"(剩余:%ld件)", (long)goodDetail.repertory];
    NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:goodDetail.mainPicture];
    UIImage *placeholderImage = [UIImage placeholderImageWithSize:titleImageView.size];
    [titleImageView sd_setImageWithURL:URL placeholderImage:placeholderImage options:SDWebImageRetryFailed];
//    _numberLab.text = @"1";

}

- (void)touchAddNumberBtn:(UIButton *)button {
    NSInteger number = _numberLab.text.integerValue;
    NSString *inventoryStr = [inventoryLab.text componentsSeparatedByString:@":"][1];
    inventoryStr = [inventoryStr componentsSeparatedByString:@"件"][0];
    NSInteger inventory = inventoryStr.integerValue;
    if (number >= inventory) {
        [MBProgressHUD showHUDWithMessage:@"没有更多的货了"];
    } else {
        _numberLab.text = [NSString stringWithFormat:@"%li", (long)(number + 1)];
    }
}

- (void)touchSubNumberBtn:(UIButton *)button {
    NSInteger number = _numberLab.text.integerValue;
    if (number <= 1) {
        [MBProgressHUD showHUDWithMessage:@"不能再少了"];
    } else {
        _numberLab.text = [NSString stringWithFormat:@"%li", (long)(number - 1)];
    }
}

- (void)touchConfirmBtn:(UIButton *)button {

    if (mGoodStandards.descriptions.allKeys.count == 1) {
        if ([_primaryStandardLab.text isEqualToString:@""] || _primaryStandardLab.text == nil) {
            [MBProgressHUD showHUDWithMessage:@"请选择完整规格"];
            return;
        }
    }
    if (mGoodStandards.descriptions.allKeys.count == 2) {
        if ([_primaryStandardLab.text isEqualToString:@""] || [_secondaryStandardLab.text isEqualToString:@""] || _primaryStandardLab.text == nil || _secondaryStandardLab.text == nil) {
            [MBProgressHUD showHUDWithMessage:@"请选择完整规格"];
            return;
        }
    }
    if (mCartItem.goods.ID == nil) {
        [MBProgressHUD showHUDWithMessage:@"您选择的商品不存在"];
        return ;
    }

    if (_delegate && [_delegate respondsToSelector:@selector(selectStandardView:didSelectConfirmButtonWithNumber:NewGoodsId:ShoppingCartGoodsId:)]) {
        [_delegate selectStandardView:self didSelectConfirmButtonWithNumber:_numberLab.text.integerValue NewGoodsId:mCartItem.goods.ID ShoppingCartGoodsId:mCartItem.ID];
    }
    [self removeFromSuperview];
    
}

- (void)touchHideSelect:(id)sender {
    [self removeFromSuperview];
}

- (void)touchCloseBtn {
    [self removeFromSuperview];
}

@end
