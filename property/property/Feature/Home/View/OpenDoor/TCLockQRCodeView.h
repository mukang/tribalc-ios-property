//
//  TCLockQRCodeView.h
//  individual
//
//  Created by 穆康 on 2017/3/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TCLockQRCodeType) {
    TCLockQRCodeTypeOneself,
    TCLockQRCodeTypeVisitor
};

@interface TCLockQRCodeView : UIView

@property (nonatomic, readonly) TCLockQRCodeType type;

@property (weak, nonatomic) UIImageView *codeImageView;
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UIButton *wechatButton;
@property (weak, nonatomic) UIButton *messageButton;

- (instancetype)initWithLockQRCodeType:(TCLockQRCodeType)type;

@end
