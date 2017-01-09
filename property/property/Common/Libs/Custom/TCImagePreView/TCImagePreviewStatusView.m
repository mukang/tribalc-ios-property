//
//  TCImagePreviewStatusView.m
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCImagePreviewStatusView.h"
#import <Masonry/Masonry.h>

@interface TCImagePreviewStatusView ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) UIImageView* failedIcon;
@property (nonatomic, strong) UILabel* failedLabel;
@property (nonatomic, strong) CADisplayLink *loadingLink;

@end


@implementation TCImagePreviewStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    _failedIcon = [UIImageView new];
    _failedIcon.image = [UIImage imageNamed:@"icon_commentupload_cancel"];
    [self addSubview:_failedIcon];
    [_failedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(30);
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(17);
    }];
    
    _failedLabel = [UILabel new];
    _failedLabel.textColor = [UIColor whiteColor];
    _failedLabel.font = [UIFont systemFontOfSize:13];
    _failedLabel.textAlignment = NSTextAlignmentCenter;
    _failedLabel.text = @"加载失败";
    [self addSubview:_failedLabel];
    [_failedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.centerX.equalTo(self);
        make.top.equalTo(_failedIcon.mas_bottom).offset(5);
    }];
}

- (void)clean
{
    [_loadingLink invalidate];
    _loadingLink = nil;
}

- (void)showLoadingAnimation
{
    [self setNeedsDisplay];
}

- (void)setStatus:(TCImagePreviewStatus)status
{
    _status = status;
    self.hidden = NO;
    self.loading = NO;
    [_loadingLink invalidate];
    _loadingLink = nil;
    switch (_status) {
        case TCImagePreviewStatusLoading:
            self.loading = YES;
            _loadingLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(showLoadingAnimation)];
            [_loadingLink setFrameInterval:1];
            [_loadingLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            self.failedIcon.hidden = YES;
            self.failedLabel.hidden = YES;
            break;
        case TCImagePreviewStatusFailed:
            self.failedIcon.hidden = NO;
            self.failedLabel.hidden = NO;
            break;
        default:
            self.hidden = YES;
            break;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (_loading) {
        BOOL isPreiOS7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
        CGFloat lineWidth = 2.f;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = 15;
        CGFloat startAngle = ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [[UIColor grayColor] set];
        [processBackgroundPath stroke];
        
        // Draw progress
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = isPreiOS7 ? kCGLineCapRound : kCGLineCapSquare;
        processPath.lineWidth = lineWidth;
        startAngle = 2 * (float)M_PI * ((int)(_loadingLink.timestamp * 100) % 100) / 100.0;
        endAngle = (0.5 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [[UIColor whiteColor] set];
        [processPath stroke];
    }
}

@end

