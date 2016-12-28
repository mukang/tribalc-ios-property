//
//  TCUserOrderTableViewCell.m
//  individual
//
//  Created by WYH on 16/11/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCUserOrderTableViewCell.h"
#import "TCImageURLSynthesizer.h"


@implementation TCUserOrderTableViewCell {
    
    
}


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"orderListCell";
    TCUserOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TCUserOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = TCRGBColor(242, 242, 242);
        [self.contentView addSubview:_backView];
        
        UIImageView *leftImageView = [[UIImageView alloc] init];
        leftImageView.backgroundColor = _backView.backgroundColor;
        leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_backView addSubview:leftImageView];
        self.leftImageView = leftImageView;
        
        UILabel *titleLab = [TCComponent createLabelWithFrame:CGRectNull AndFontSize:TCRealValue(12) AndTitle:@""];
        [_backView addSubview:titleLab];
        self.titleLab = titleLab;
        
        UILabel *priceLab = [self getNumberOrPriceLabelWithFrame:CGRectNull];
        [_backView addSubview:priceLab];
        self.priceLab = priceLab;
        
        UILabel *numberLab = [self getNumberOrPriceLabelWithFrame:CGRectNull];
        [_backView addSubview:numberLab];
        self.numberLab = numberLab;

        
        UILabel *standardLab = [[UILabel alloc] init];
        standardLab.textColor = TCRGBColor(154, 154, 154);
        standardLab.font = [UIFont systemFontOfSize:TCRealValue(12)];
        [_backView addSubview:standardLab];
        self.standardLab = standardLab;
        
        
    }
    return self;
}


//- (void)setOrderListOrderItem:(TCOrderItem *)orderItem {
//    _orderItem = orderItem;
//    [self setupOrderListFrame];
//    [self setupOrderListData];
//}
//
//- (void)setOrderDetailOrderItem:(TCOrderItem *)orderItem {
//    _orderItem = orderItem;
//    [self setupOrderDetailFrame];
//    [self setupOrderDetailData];
//}
//
//- (void)setupOrderDetailFrame {
//    CGRect screenRect = [UIScreen mainScreen].bounds;
//    CGFloat height = TCRealValue(96.5);
//    _backView.frame = CGRectMake(TCRealValue(20), height / 2 - TCRealValue(79) / 2, screenRect.size.width - TCRealValue(40), height);
//    _backView.backgroundColor = [UIColor whiteColor];
//    self.leftImageView.frame = CGRectMake(TCRealValue(8), 0, TCRealValue(79), TCRealValue(79));
//    self.titleLab.frame = CGRectMake(self.leftImageView.x + self.leftImageView.width + TCRealValue(9), self.leftImageView.y + TCRealValue(7), screenRect.size.width - self.leftImageView.x - self.leftImageView.width - TCRealValue(13) - TCRealValue(60), TCRealValue(14));
//    [self setBoldNumberLabel:_orderItem.amount];
//    self.priceLab.frame = CGRectMake(self.leftImageView.x + self.leftImageView.width + TCRealValue(1), self.titleLab.y + self.titleLab.height + TCRealValue(5), TCScreenWidth - TCRealValue(40) - self.leftImageView.x - self.leftImageView.width - TCRealValue(1), TCRealValue(14));
//
//    self.standardLab.frame = CGRectMake(self.titleLab.x, self.numberLab.y + TCRealValue(1), self.numberLab.x - self.leftImageView.x - self.leftImageView.width - TCRealValue(13), TCRealValue(13));
//}

- (void)setupOrderDetailData {
//    [self setupOrderListData];
    self.standardLab.font = [UIFont systemFontOfSize:TCRealValue(13)];
    self.priceLab.font = [UIFont fontWithName:BOLD_FONT size:TCRealValue(14)];
    UIView *topLineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), 0, TCScreenWidth - TCRealValue(40), TCRealValue(0.5))];
    [self addSubview:topLineView];
    
    UIView *downLineView = [TCComponent createGrayLineWithFrame:CGRectMake(TCRealValue(20), TCRealValue(96.5) - TCRealValue(0.5), TCScreenWidth - TCRealValue(40), TCRealValue(0.5))];
    [self addSubview:downLineView];
}

- (void)setupOrderListFrame {
    _backView.frame = CGRectMake(TCRealValue(20), TCRealValue(1), TCScreenWidth - TCRealValue(20) - TCRealValue(20), TCRealValue(77 - 2));
    self.leftImageView.frame = CGRectMake(_backView.height / 2 - TCRealValue(71.5) / 2, _backView.height / 2 - TCRealValue(71.5) / 2, TCRealValue(71.5), TCRealValue(71.5));
    self.titleLab.frame = CGRectMake(self.leftImageView.x + self.leftImageView.width + TCRealValue(9), 12, TCRealValue(337 / 2), TCRealValue(12));
    self.priceLab.frame = CGRectMake(self.titleLab.x + self.titleLab.width + TCRealValue(1), self.titleLab.y, TCScreenWidth - TCRealValue(20) - TCRealValue(11) - self.titleLab.x - self.titleLab.width - TCRealValue(1) - TCRealValue(20), TCRealValue(13));
    self.numberLab.frame = CGRectMake(self.priceLab.x, self.priceLab.y + self.priceLab.height + TCRealValue(5), self.priceLab.width, TCRealValue(13));
    self.standardLab.frame = CGRectMake(self.leftImageView.x + self.leftImageView.width + TCRealValue(9), _backView.height - TCRealValue(10) - TCRealValue(12), TCScreenWidth - TCRealValue(20) - TCRealValue(71.5) - TCRealValue(20) - TCRealValue(9), TCRealValue(13));
    
}
//
//- (void)setupOrderListData {
//    [self.leftImageView sd_setImageWithURL:[TCImageURLSynthesizer synthesizeImageURLWithPath:_orderItem.goods.mainPicture]];
//    [self setTitleLabWithText:_orderItem.goods.name];
//    [self setPriceLabel:_orderItem.goods.salePrice];
//    [self setNumberLabel:_orderItem.amount];
//    [self setSelectedStandard:_orderItem.goods.standardSnapshot];
//}


- (UILabel *)getNumberOrPriceLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:TCRealValue(12)];
    label.textAlignment = NSTextAlignmentRight;
    
    return label;
}



- (void)setSelectedStandard:(NSString *)standardStr{

    NSDictionary *standard = [self getSelectesStandardDic:standardStr];
    standardStr = @"";
    if (standard[@"secondary"] == NULL && standard[@"primary"] != NULL) {
        standardStr = [NSString stringWithFormat:@"%@ : %@", standard[@"primary"][@"label"], standard[@"primary"][@"types"]];
    } else if (standard[@"secondary"] != NULL) {
        standardStr = [NSString stringWithFormat:@"%@ : %@      %@ : %@", standard[@"primary"][@"label"], standard[@"primary"][@"types"], standard[@"secondary"][@"label"], standard[@"secondary"][@"types"]];
    }
    self.standardLab.text = standardStr;
    
}

- (NSDictionary *)getSelectesStandardDic:(NSString *)standard {
    if (![standard containsString:@":"]) {
        return nil;
    }
    if ([standard containsString:@":"] && ![standard containsString:@"|"]) {
        NSArray *standardArr = [standard componentsSeparatedByString:@":"];
        return @{
                 @"primary":@{
                         @"label":standardArr[0],
                         @"types":standardArr[1]
                         }
                 };
    }
    if ([standard containsString:@":"] && [standard containsString:@"|"]) {
        NSArray *standardArr = [standard componentsSeparatedByString:@"|"];
        NSArray *primaryArr = [standardArr[0] componentsSeparatedByString:@":"];
        NSArray *secondaryArr = [standardArr[1] componentsSeparatedByString:@":"];
        return @{
                 @"primary": @{ @"label":primaryArr[0], @"types":primaryArr[1] },
                 @"secondary":@{  @"label":secondaryArr[0], @"types":secondaryArr[1] }
                 };
    }
    
    return nil;
}

- (void)setNumberLabel:(float)number {
    NSString *numberStr = [NSString stringWithFormat:@"x %@", @([NSString stringWithFormat:@"%f", number].floatValue)];
    self.numberLab.text = numberStr;
}

- (void)setBoldNumberLabel:(float)number {
    NSString *numberStr = [NSString stringWithFormat:@"x%@", @([NSString stringWithFormat:@"%f", number].floatValue)];
    self.numberLab.font = [UIFont systemFontOfSize:TCRealValue(13)];
    self.numberLab.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
    
    UIImageView *writeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_backView.width - TCRealValue(13), self.leftImageView.height + self.leftImageView.y - TCRealValue(20) + TCRealValue(1), TCRealValue(11), TCRealValue(11))];
    writeImgView.image = [UIImage imageNamed:@"order_write"];
    [_backView addSubview:writeImgView];
    
    self.numberLab.frame = CGRectMake(writeImgView.x - TCRealValue(50) - TCRealValue(2), self.leftImageView.height + self.leftImageView.y - TCRealValue(20), TCRealValue(50), TCRealValue(13));
    self.numberLab.text = numberStr;
    
    
}

- (void)setPriceLabel:(float)price {
    NSString *priceStr = [NSString stringWithFormat:@"￥%@", @([NSString stringWithFormat:@"%f", price].floatValue)];
    self.priceLab.text = priceStr;
}

//- (void)setTitleLabWithText:(NSString *)text {
//    self.titleLab.lineBreakMode = NSLineBreakByWordWrapping;
//    self.titleLab.numberOfLines = TCRealValue(2);
//    self.titleLab.font = [UIFont systemFontOfSize:self.titleLab.height];
//    NSString *salePriceStr = [NSString stringWithFormat:@"￥%@", @([NSString stringWithFormat:@"%f", _orderItem.goods.salePrice].floatValue)];
//    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: self.titleLab.font}];
//    CGSize priceSize = [salePriceStr sizeWithAttributes:@{NSFontAttributeName: self.priceLab.font}];
//    if (size.width + 2 > self.titleLab.width) {
//        [self.titleLab setHeight:TCRealValue((self.titleLab.height * 2) + TCRealValue(5))];
//    }
//    if (size.width + 2 > self.titleLab.width * 2 - priceSize.width) {
//        self.priceLab.y = self.titleLab.y + self.titleLab.height;
//    }
//    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithString:text];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    NSRange range = NSMakeRange(0, text.length);
//    [textAttr addAttribute:NSParagraphStyleAttributeName value:style range:range];
//    self.titleLab.attributedText = textAttr;
//    
//}

- (UILabel *)getStandardLabelWithOrigin:(CGPoint)point AndText:(NSString *)text{
    
    UILabel *label = [TCComponent createLabelWithText:text AndFontSize:TCRealValue(12)];
    [label setOrigin:point];
    label.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
    
    return label;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
