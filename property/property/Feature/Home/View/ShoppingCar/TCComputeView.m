//
//  TCComputeView.m
//  individual
//
//  Created by WYH on 16/11/29.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCComputeView.h"

@implementation TCComputeView {
    UIView *leftLine;
    UIView *rightLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1].CGColor;
        self.layer.cornerRadius = TCRealValue(3);
        
        _addBtn = [self getComputeBtnWithOrigin:CGPointMake(self.width - TCRealValue(26), 0) AndText:@"+"];
        _addBtn.width = TCRealValue(26);
        [self addSubview:_addBtn];
        
        rightLine = [TCComponent createGrayLineWithFrame:CGRectMake(_addBtn.x - TCRealValue(0.5), 0, TCRealValue(0.5), _addBtn.height)];
        [self addSubview:rightLine];
        
        _countLab = [TCComponent createLabelWithFrame:CGRectMake(rightLine.x - TCRealValue(26), 0, TCRealValue(26), rightLine.height) AndFontSize:12 AndTitle:@"1"];
        _countLab.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
        _countLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countLab];

        leftLine = [TCComponent createGrayLineWithFrame:CGRectMake(_countLab.x - TCRealValue(0.5), 0, TCRealValue(0.5), rightLine.height)];
        [self addSubview:leftLine];

        _subBtn = [self getComputeBtnWithOrigin:CGPointMake(leftLine.x - TCRealValue(26), 0) AndText:@"-"];
        _subBtn.width = TCRealValue(26);
        [self addSubview:_subBtn];
        
        self.width = _addBtn.width + rightLine.width + _countLab.width + leftLine.width + _subBtn.width;
    }
    
    return self;
}

- (void)setCount:(NSInteger)count {
    NSString *countStr = [NSString stringWithFormat:@"%li", (long)count];
    _countLab.text = countStr;
    if (count > 99) {
        [_countLab sizeToFit];
        leftLine.x = _countLab.x - TCRealValue(0.5);
        _subBtn.x = leftLine.x - TCRealValue(26);
        self.width = _addBtn.width + rightLine.width + _countLab.width + leftLine.width + _subBtn.width;
    }
}

- (UIButton *)getComputeBtnWithOrigin:(CGPoint)point AndText:(NSString *)text {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(point.x, point.y, TCRealValue(26), TCRealValue(20))];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:TCRealValue(12)];
    
    return btn;
}

@end
