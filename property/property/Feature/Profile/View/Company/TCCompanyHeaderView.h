//
//  TCCompanyHeaderView.h
//  individual
//
//  Created by 穆康 on 2016/12/9.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TCCommonLibs/TCImagePlayerView.h>
@class TCCompanyInfo;

@interface TCCompanyHeaderView : UIView

@property (strong, nonatomic) TCCompanyInfo *companyInfo;

@property (weak, nonatomic) TCImagePlayerView *imagePalyerView;
@property (weak, nonatomic) UIView *logoBgView;
@property (weak, nonatomic) UIImageView *logoImageView;

@end
