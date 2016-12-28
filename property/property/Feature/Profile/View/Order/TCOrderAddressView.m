//
//  TCOrderAddressView.m
//  individual
//
//  Created by WYH on 16/11/26.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCOrderAddressView.h"
#import "TCBuluoApi.h"


@implementation TCOrderAddressView {
    UILabel *receiverLab;
    UILabel *phoneLab;
    UILabel *addressLab;
}

- (void)initUIWithName:(NSString *)name AndPhone:(NSString *)phone AndAddress:(NSString *)address {
    CGRect screen = [UIScreen mainScreen].bounds;
    UIImage *backImg = [UIImage imageNamed:@"order_address_back"];
    self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    
    UIImageView *backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, TCRealValue(7.5), screen.size.width, TCRealValue(96))];
    backImgView.image = backImg;
    [self addSubview:backImgView];
    
    receiverLab = [self getReceiverLabelWithFrame:CGRectMake(TCRealValue(32), TCRealValue(20), TCRealValue(152), TCRealValue(14)) AndName:name];
    [backImgView addSubview:receiverLab];
    
    phoneLab = [self getPhoneLabWithFrame:CGRectMake(receiverLab.x + receiverLab.width, receiverLab.y, self.width - TCRealValue(77) - receiverLab.x - receiverLab.width, TCRealValue(14)) AndPhoneStr:phone];
    [backImgView addSubview:phoneLab];
    
    UIButton *locationLogo = [TCComponent createImageBtnWithFrame:CGRectMake(TCRealValue(20), backImgView.height / 2 - TCRealValue(4), TCRealValue(12), TCRealValue(12)) AndImageName:@"order_location"];
    [backImgView addSubview:locationLogo];
    
    addressLab = [self getAddressLabelWithFrame:CGRectMake(receiverLab.x + TCRealValue(4), locationLogo.y, self.width - receiverLab.x - TCRealValue(4) - (self.width - phoneLab.x - phoneLab.width), TCRealValue(13)) AndText:address];
    [backImgView addSubview:addressLab];
    
    UIButton *rightArrow = [self getRightArrowButtonWithFrame:CGRectMake(self.width - TCRealValue(38), TCRealValue(31), TCRealValue(9), TCRealValue(16))];
    [backImgView addSubview:rightArrow];

}

- (instancetype)initWithOrigin:(CGPoint)point WithShippingAddress:(TCUserShippingAddress *)shippingAddress {
    self = [super initWithFrame:CGRectMake(point.x, point.y, TCScreenWidth, TCRealValue(107))];
    if (self) {
        _shippingAddress = shippingAddress;
        NSArray *addressArr = [self getAddressArr:shippingAddress];
        NSString *name = addressArr[0];
        NSString *phone = addressArr[1];
        NSString *address = addressArr[2];
        [self initUIWithName:name AndPhone:phone AndAddress:address];
        if (_shippingAddress == nil) {
            receiverLab.text = @"请添加收货地址";
            receiverLab.frame = CGRectMake(TCRealValue(32) + TCRealValue(5), TCRealValue(96 / 2 - 4), self.width - TCRealValue(32), TCRealValue(14));
        }

    }
    
    return self;
}

- (instancetype)initWithOrigin:(CGPoint)point AndName:(NSString *)name AndPhone:(NSString *)phone AndAddress:(NSString *)address{
    self = [super initWithFrame:CGRectMake(point.x, point.y, TCScreenWidth, TCRealValue(107))];
    if (self) {
        [self initUIWithName:name AndPhone:phone AndAddress:address];
    }
    
    return self;
}

- (void)setAddress:(TCUserShippingAddress *)shippingAddress {
    _shippingAddress = shippingAddress;
    NSArray *addressArr = [self getAddressArr:shippingAddress];
    receiverLab.text = [NSString stringWithFormat:@"收货人 : %@", addressArr[0]];
    receiverLab.frame = CGRectMake(TCRealValue(32), TCRealValue(20), TCRealValue(152), TCRealValue(14));
    phoneLab.text = addressArr[1];
    phoneLab.frame = CGRectMake(receiverLab.x + receiverLab.width, receiverLab.y, self.width - TCRealValue(77) - receiverLab.x - receiverLab.width, TCRealValue(14));
    [self setAddressLabel:addressLab Text:addressArr[2]];
    
}

- (NSArray *)getAddressArr:(TCUserShippingAddress *)shippingAddress {
    if (shippingAddress) {
        return @[ shippingAddress.name, shippingAddress.phone, [NSString stringWithFormat:@"%@%@%@%@", shippingAddress.province, shippingAddress.city, shippingAddress.district, shippingAddress.address] ];
    } else {
        return @[@"", @"", @""];
    }
}



- (UIButton *)getRightArrowButtonWithFrame:(CGRect)frame {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    UIImage *arrowImg = [UIImage imageNamed:@"goods_select_standard"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:arrowImg];
    [button addSubview:imgView];
    return button;
}

- (UILabel *)getReceiverLabelWithFrame:(CGRect)frame AndName:(NSString *)name {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    NSString *nameStr = [NSString stringWithFormat:@"收货人 : %@", name];
    label.text = nameStr;
    label.font = [UIFont fontWithName:BOLD_FONT size:TCRealValue(14)];
    
    return label;
}

- (UILabel *)getPhoneLabWithFrame:(CGRect)frame AndPhoneStr:(NSString *)phone {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = phone;
    label.textAlignment = NSTextAlignmentRight;
    label.font = [UIFont fontWithName:BOLD_FONT size:14];
    
    return label;
}


- (void)setAddressLabel:(UILabel *)label Text:(NSString *)text {
    label.frame = CGRectMake(receiverLab.x + TCRealValue(4),  TCRealValue(96) / 2 - TCRealValue(4), self.width - receiverLab.x - TCRealValue(4) - (self.width - phoneLab.x - phoneLab.width), TCRealValue(13));
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = TCRealValue(2);
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    if (size.width > label.width) {
        [label setHeight:(TCRealValue(13) * 2) + TCRealValue(4)];
        label.y -= TCRealValue(2);
    }
    text = text == nil ? @"" : text;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    NSRange range = NSMakeRange(0, text.length);
    [attr addAttribute:text value:style range:range];
    label.attributedText = attr;

}

- (UILabel *)getAddressLabelWithFrame:(CGRect)frame AndText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.font = [UIFont systemFontOfSize:TCRealValue(12)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = TCRealValue(2);
    
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    if (size.width > label.width) {
        [label setHeight:(label.height * 2) + TCRealValue(4)];
        label.y -= TCRealValue(2);
    }
    
    text = text == nil ? @"" : text;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    NSRange range = NSMakeRange(0, text.length);
    [attr addAttribute:text value:style range:range];
    label.attributedText = attr;
    
    return label;
}



@end
