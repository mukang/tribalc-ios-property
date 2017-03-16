//
//  TCLockQRCodeViewController.m
//  individual
//
//  Created by 穆康 on 2017/3/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCLockQRCodeViewController.h"
#import "TCNavigationController.h"

#import "TCLockQRCodeTitleView.h"

#import "TCBuluoApi.h"

#import "WXApiManager.h"
#import "TCImageCompressHandler.h"

#import <MessageUI/MessageUI.h>

#define navBarH     64.0

@interface TCLockQRCodeViewController () <WXApiManagerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) UINavigationBar *navBar;
@property (weak, nonatomic) UINavigationItem *navItem;

@property (weak, nonatomic) UILabel *timeLabel;
@property (weak, nonatomic) TCLockQRCodeView *QRCodeView;
@property (weak, nonatomic) TCLockQRCodeTitleView *titleView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) BOOL originalInteractivePopGestureEnabled;

@end

@implementation TCLockQRCodeViewController {
    __weak TCLockQRCodeViewController *weakSelf;
}

- (instancetype)initWithLockQRCodeType:(TCLockQRCodeType)type {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        weakSelf = self;
        _type = type;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavBar];
    [self setupSubviews];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.fromController) {
        TCNavigationController *nav = (TCNavigationController *)self.navigationController;
        self.originalInteractivePopGestureEnabled = nav.enableInteractivePopGesture;
        nav.enableInteractivePopGesture = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.fromController) {
        TCNavigationController *nav = (TCNavigationController *)self.fromController.navigationController;
        nav.enableInteractivePopGesture = self.originalInteractivePopGestureEnabled;
    }
}

#pragma mark - Private Methods

- (void)setupNavBar {
    self.hideOriginalNavBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, navBarH)];
    [navBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    [navBar setBackgroundImage:[UIImage imageNamed:@"TransparentPixel"] forBarMetrics:UIBarMetricsDefault];
    [self.view addSubview:navBar];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIImage *backImage = [[UIImage imageNamed:@"nav_back_item"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(handleClickBackButton:)];
    [navBar setItems:@[navItem]];
    
    self.navBar = navBar;
    self.navItem = navItem;
}

- (void)setupSubviews {
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.image = [UIImage imageNamed:@"lock_QR_code_bg"];
    [self.view insertSubview:bgImageView belowSubview:self.navBar];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(weakSelf.view);
    }];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    TCLockQRCodeView *QRCodeView = [[TCLockQRCodeView alloc] initWithLockQRCodeType:self.type];
    [self.view addSubview:QRCodeView];
    self.QRCodeView = QRCodeView;
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(14);
        make.leading.trailing.equalTo(QRCodeView);
    }];
    [QRCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(TCRealValue(TCRealValue(329)), TCRealValue(325)));
        make.centerX.equalTo(weakSelf.view);
    }];
    
    CGFloat timeLabelTop, QRCodeViewTop;
    if (self.type == TCLockQRCodeTypeOneself) {
        timeLabelTop = navBarH + TCRealValue(46.5);
        QRCodeViewTop = navBarH + TCRealValue(69);
    } else {
        timeLabelTop = navBarH + TCRealValue(31);
        QRCodeViewTop = navBarH + TCRealValue(153.5);
        
        TCLockQRCodeTitleView *titleView = [[TCLockQRCodeTitleView alloc] init];
        [self.view addSubview:titleView];
        self.titleView = titleView;
        [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(TCRealValue(329), TCRealValue(90)));
            make.top.equalTo(weakSelf.view).offset(navBarH + TCRealValue(53));
            make.centerX.equalTo(weakSelf.view);
        }];
        
        [QRCodeView.wechatButton addTarget:self action:@selector(handleClickWechatButton:) forControlEvents:UIControlEventTouchUpInside];
        [QRCodeView.messageButton addTarget:self action:@selector(handleClickMessageButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (![WXApi isWXAppInstalled]) QRCodeView.wechatButton.enabled = NO;
        if (![MFMessageComposeViewController canSendAttachments]) QRCodeView.messageButton.enabled = NO;
    }
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(timeLabelTop);
    }];
    [QRCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(QRCodeViewTop);
    }];
}

- (void)loadData {
    if (self.type == TCLockQRCodeTypeOneself) {
        TCVisitorInfo *info = [[TCVisitorInfo alloc] init];
        info.equipId = self.equipID;
        [MBProgressHUD showHUD:YES];
        [[TCBuluoApi api] fetchLockKeyWithVisitorInfo:info result:^(TCLockKey *lockKey, NSError *error) {
            if (lockKey) {
                [MBProgressHUD hideHUD:YES];
                [weakSelf reloadUIWithLockKey:lockKey];
            } else {
                NSString *reason = error.localizedDescription ?: @"请稍后再试";
                [MBProgressHUD showHUDWithMessage:[NSString stringWithFormat:@"获取数据失败，%@", reason]];
            }
        }];
    } else {
        [self reloadUIWithLockKey:self.lockKey];
    }
}

- (void)reloadUIWithLockKey:(TCLockKey *)lockKey {
    NSString *endTimeStr = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:lockKey.endTime / 1000]];
    self.timeLabel.text = [NSString stringWithFormat:@"有效期截止：%@", endTimeStr];
    self.QRCodeView.codeImageView.image = [self generateQRCodeImageWithCodeString:lockKey.key size:CGSizeMake(TCRealValue(180), TCRealValue(180))];
    if (self.type == TCLockQRCodeTypeOneself) {
        self.QRCodeView.nameLabel.text = [NSString stringWithFormat:@"设备名称：%@", lockKey.equipName];
    } else {
        self.titleView.deviceLabel.text = [NSString stringWithFormat:@"设备名称：%@", lockKey.equipName];
        self.titleView.visitorLabel.text = [NSString stringWithFormat:@"访客姓名：%@", lockKey.name];
        self.titleView.phoneLabel.text = [NSString stringWithFormat:@"访客电话：%@", lockKey.phone];
    }
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

#pragma mark - Wechat

- (void)shareQRCodeToWechat {
    [WXApiManager sharedManager].delegate = self;
    
    UIImage *codeImage = self.QRCodeView.codeImageView.image;
    NSData *imageData = [TCImageCompressHandler compressImage:codeImage toByte:(100 * 1000)];
    NSData *thumbData = [TCImageCompressHandler compressImage:codeImage toByte:(30 * 1000)];
    WXMediaMessage *message = [WXMediaMessage message];
    message.thumbData = thumbData;
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = imageData;
    message.mediaObject = imageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

#pragma mark - WXApiManagerDelegate

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    if (response.errCode == 0) {
        [MBProgressHUD showHUDWithMessage:@"分享成功"];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultSent) {
        [MBProgressHUD showHUDWithMessage:@"分享成功"];
    }
}

#pragma mark - Actions

- (void)handleClickBackButton:(UIBarButtonItem *)sender {
    if (self.fromController) {
        [self.navigationController popToViewController:self.fromController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleClickWechatButton:(UIButton *)sender {
    [self shareQRCodeToWechat];
}

- (void)handleClickMessageButton:(UIButton *)sender {
    NSString *uti = @"image/jpeg";
    if ([MFMessageComposeViewController isSupportedAttachmentUTI:uti]) {
        UIImage *codeImage = self.QRCodeView.codeImageView.image;
        NSData *imageData = [TCImageCompressHandler compressImage:codeImage toByte:(100 * 1000)];
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        [vc addAttachmentData:imageData typeIdentifier:uti filename:@"QRCode.jpg"];
        vc.messageComposeDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Override Methods

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _dateFormatter.dateFormat = @"MM月dd日 HH时mm分";
    }
    return _dateFormatter;
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
