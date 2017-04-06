//
//  TCMyLockQRCodeController.m
//  individual
//
//  Created by 王帅锋 on 17/4/5.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCMyLockQRCodeController.h"
#import "TCLockQRCodeView.h"
#import "TCVisitorInfo.h"
#import "TCBuluoApi.h"

#define navBarH     64.0

@interface TCMyLockQRCodeController ()

@property (weak, nonatomic) UINavigationBar *navBar;

@property (weak, nonatomic) UINavigationItem *navItem;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UILabel *secondLabel;

@property (strong, nonatomic) UILabel *deviceLabel;

@property (strong, nonatomic) TCLockQRCodeView *qRCodeView;

@property (strong, nonatomic) UIView *coverView;

@property (strong, nonatomic) UIButton *refreshBtn;

@property (assign, nonatomic) NSInteger second;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TCMyLockQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self setUpViews];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeGetPasswordTimer];
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.hideOriginalNavBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, navBarH)];
    [navBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    [navBar setBackgroundImage:[UIImage imageNamed:@"TransparentPixel"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:navBar];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"选择门锁"];
    navBar.titleTextAttributes = @{
                                   NSFontAttributeName : [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [UIColor whiteColor]
                                   };
    UIImage *backImage = [[UIImage imageNamed:@"nav_back_item"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(handleClickBackButton:)];
    [navBar setItems:@[navItem]];
    
    self.navBar = navBar;
    self.navItem = navItem;
}

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpViews {
    
    UIView *bgView = [[UIView alloc] init];
    [self.view insertSubview:bgView belowSubview:self.navBar];
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.image = [UIImage imageNamed:@"lock_QR_code_bg"];
    [bgView addSubview:bgImageView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"myLockQRTimeOutBackgroundImage"]];
    [bgView addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *timeTitle = [[UILabel alloc] init];
    timeTitle.text = @"有效时间";
    timeTitle.textAlignment = NSTextAlignmentCenter;
    timeTitle.font = [UIFont systemFontOfSize:TCRealValue(11)];
    timeTitle.textColor = [UIColor whiteColor];
    [self.imageView addSubview:timeTitle];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:TCRealValue(32)];
    [self.imageView addSubview:timeLabel];
    timeLabel.text = @"0";
    self.secondLabel = timeLabel;
    
    UILabel *unitLabel = [[UILabel alloc] init];
    unitLabel.textColor = [UIColor whiteColor];
    unitLabel.font = [UIFont systemFontOfSize:TCRealValue(11)];
    unitLabel.text = @"秒";
    unitLabel.textAlignment = NSTextAlignmentCenter;
    [self.imageView addSubview:unitLabel];
    
    UILabel *deviceL = [[UILabel alloc] init];
    deviceL.textColor = [UIColor whiteColor];
    deviceL.font = [UIFont systemFontOfSize:TCRealValue(16)];
    [self.imageView addSubview:deviceL];
    
    deviceL.textAlignment = NSTextAlignmentCenter;
    self.deviceLabel = deviceL;
    
    TCLockQRCodeView *QRCodeView = [[TCLockQRCodeView alloc] initWithLockQRCodeType:TCLockQRCodeTypeOneself];
    [self.view addSubview:QRCodeView];
    self.qRCodeView = QRCodeView;
    
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.alpha = 0.7;
    coverView.hidden = YES;
    [QRCodeView addSubview:coverView];
    self.coverView = coverView;
    
    self.refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.refreshBtn setImage:[UIImage imageNamed:@"myLockQRRefresh"] forState:UIControlStateNormal];
    self.refreshBtn.hidden = YES;
    [self.refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [QRCodeView addSubview:self.refreshBtn];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgView);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bgView);
    }];
    
    [timeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView).offset(TCRealValue(164));
        make.left.right.equalTo(self.imageView);
        make.height.equalTo(@TCRealValue(14));
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeTitle.mas_bottom);
        make.left.right.equalTo(timeTitle);
        make.height.equalTo(@TCRealValue(32));
    }];
    
    [unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel.mas_bottom);
        make.right.left.equalTo(timeTitle);
        make.height.equalTo(@TCRealValue(14));
    }];
    
    [deviceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView).offset(TCRealValue(243));
        make.left.right.equalTo(self.imageView);
    }];
    
    [QRCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imageView).offset(-TCRealValue(157));
        make.centerX.equalTo(self.imageView);
        make.width.height.equalTo(@TCRealValue(180));
    }];
    
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(QRCodeView);
    }];
    
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(QRCodeView);
        make.height.width.equalTo(@TCRealValue(60));
    }];
}

- (void)refresh {
    [self loadData];
}

- (void)loadData {
    TCVisitorInfo *info = [[TCVisitorInfo alloc] init];
    info.equipId = self.equipID;
    [MBProgressHUD showHUD:YES];
    @WeakObj(self)
    [[TCBuluoApi api] fetchLockKeyWithVisitorInfo:info result:^(TCLockKey *lockKey, NSError *error) {
        @StrongObj(self)
        if (lockKey) {
            [MBProgressHUD hideHUD:YES];
            [self reloadUIWithLockKey:lockKey];
            self.imageView.image = [UIImage imageNamed:@"myLockQRBackgroundImage"];
            self.coverView.hidden = YES;
            self.refreshBtn.hidden = YES;
        } else {
            self.refreshBtn.hidden = NO;
            NSString *reason = error.localizedDescription ?: @"请稍后再试";
            [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取数据失败，%@", reason]];
        }
    }];
}

- (void)reloadUIWithLockKey:(TCLockKey *)lockKey {
    
    self.second = (NSInteger)(lockKey.endTime/1000 - [[NSDate date] timeIntervalSince1970]);
    self.secondLabel.text = [NSString stringWithFormat:@"%ld",(long)self.second];
    self.deviceLabel.text = [NSString stringWithFormat:@"设备名称：%@",lockKey.equipName];
    self.qRCodeView.codeImageView.image = [self generateQRCodeImageWithCodeString:@"sssssssssssssssssss" size:CGSizeMake(TCRealValue(180), TCRealValue(180))];
    [self addGetPasswordTimer];
}

- (void)changeTimeLabel {
    self.second --;
    if (self.second <= 0) {
        self.second = 0;
        [self removeGetPasswordTimer];
        self.coverView.hidden = NO;
        self.refreshBtn.hidden = NO;
        self.imageView.image = [UIImage imageNamed:@"myLockQRTimeOutBackgroundImage"];
        self.deviceLabel.text = @"您的二维码超时，请您重新获取";
    }
    self.secondLabel.text = [NSString stringWithFormat:@"%ld", (long)self.second];
}

#pragma mark - timer

- (void)addGetPasswordTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTimeLabel) userInfo:nil repeats:YES];
}

- (void)removeGetPasswordTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc {
    [self removeGetPasswordTimer];
}


#pragma mark - Generate QRCode

- (UIImage *)generateQRCodeImageWithCodeString:(NSString *)codeString size:(CGSize)size {
    if (codeString.length) {
        NSData *data = [codeString dataUsingEncoding:NSUTF8StringEncoding];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        CIImage *outputImage = filter.outputImage;
        
        return [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:size.width];
    } else {
        return nil;
    }
}

/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
