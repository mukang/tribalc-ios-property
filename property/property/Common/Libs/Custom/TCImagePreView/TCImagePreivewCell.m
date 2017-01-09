//
//  TCImagePreivewCell.m
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCImagePreivewCell.h"
#import "TCImagePreviewStatusView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TCImagePreivewCell ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) TCImagePreviewStatusView* statusView;

@property (nonatomic, strong) UIImage * currentImage;
@end

@implementation TCImagePreivewCell

+ (CGRect)imageContainerRectWithImage:(UIImage*)image withSize:(CGSize)size
{
    CGFloat imageContainerViewX = 0;
    CGFloat imageContainerViewY = 0;
    CGFloat imageContainerViewHeight = 0;
    CGFloat imageContainerViewWidth = size.width;
    
    if (image.size.height / image.size.width > size.height / size.width) {
        imageContainerViewHeight = floor(image.size.height / (image.size.width / size.width));
    } else {
        CGFloat height = image.size.height / image.size.width * size.width;
        if (height < 1 || isnan(height)) height = size.height;
        height = floor(height);
        imageContainerViewHeight = height;
        imageContainerViewY = (size.height - height)/2.0;
    }
    if (imageContainerViewHeight > size.height && imageContainerViewHeight - size.height <= 1) {
        imageContainerViewHeight = size.height;
    }
    
    return CGRectMake(imageContainerViewX, imageContainerViewY, imageContainerViewWidth, imageContainerViewHeight);
}

- (void)setModel:(TCImagePreviewObject *)model
{
    _model = model;
    _showFullImage = NO;
    _currentImage = nil;
    UIImage* placeholder = _model.thumbnail ?: [UIImage imageNamed:@"image_preview_thumbnail"];
//    [_imageView sd_cancelCurrentAnimationImagesLoad];
    _statusView.status = TCImagePreviewStatusLoading;
    _imageView.userInteractionEnabled = NO;
    @WeakObj(self)
    _scrollView.userInteractionEnabled = NO;
    
    __block BOOL exist = NO;
    
    [[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:_model.imageUrl] completion:^(BOOL isInCache) {
        exist = isInCache;
    }];
    //BOOL exist = [[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:_model.imageUrl]];
    CGSize imageSize = placeholder.size;
    BOOL zoomOutPlaceholder = NO;
    if (imageSize.width > self.frame.size.width || imageSize.height > self.frame.size.height) {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        zoomOutPlaceholder = YES;
    } else {
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    [_imageView sd_setImageWithURL: [NSURL URLWithString:_model.imageUrl] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @StrongObj(self)
        if (error) {
            self.statusView.status = TCImagePreviewStatusFailed;
        } else {
            
            self.scrollView.userInteractionEnabled = YES;
            self.showFullImage = YES;
            self.statusView.status = TCImagePreviewStatusNormal;
            self.imageView.contentMode = UIViewContentModeScaleToFill;
            self.imageView.image = image;
            self.currentImage = image;
            self.imageView.userInteractionEnabled = YES;
            if (exist) {
                [self resizeSubviews];
            } else {
                if (!zoomOutPlaceholder) {
                    self.imageContainerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
                    self.imageContainerView.center = self.scrollView.center;
                    self.imageView.frame = self.imageContainerView.bounds;
                }
                [UIView animateWithDuration:0.2 animations:^{
                    [self resizeSubviews];
                }];
            }
        }
    }];
    [self resizeSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.clipsToBounds = YES;
        UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_imageView addGestureRecognizer:longPressGesture];
        [_imageContainerView addSubview:_imageView];
        
        _statusView = [[TCImagePreviewStatusView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _statusView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:_statusView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
    }
    return self;
}

- (void)dealloc
{
    [_statusView clean];
}

- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    
    _imageContainerView.frame = [TCImagePreivewCell imageContainerRectWithImage:_imageView.image withSize:self.frame.size];
    if (!_showFullImage && _imageContainerView.frame.size.height > self.frame.size.height && _imageView.contentMode == UIViewContentModeCenter) {
        _imageContainerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    
    _scrollView.contentSize = CGSizeMake(self.frame.size.width, MAX(_imageContainerView.frame.size.height, self.frame.size.height));
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.frame.size.height <= self.frame.size.height ? NO : YES;
    
    _imageView.frame = _imageContainerView.bounds;
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    if (!_scrollView.userInteractionEnabled) {
        return;
    }
    
    
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock(self);
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state == UIGestureRecognizerStateBegan){
        if(self.currentImage){
            
//            TTActionSheet *actionSheet = [[TTActionSheet alloc] initWithTitle:nil
//                                                                     delegate:nil
//                                                            cancelButtonTitle:TTLocalizedString(@"取消", @"取消")
//                                                       destructiveButtonTitle:TTLocalizedString(@"保存图片", @"保存图片")
//                                                            otherButtonTitles:nil];
//            @weakify(self);
//            [[actionSheet rac_buttonClickedSignal] subscribeNext:^(id x) {
//                @strongify(self);
//                if ([x integerValue] == 0) {
//                    ALAssetsLibrary * library = [ALAssetsLibrary new];
//                    CGImageRef imageRef = self.currentImage.CGImage;
//                    [library writeImageToSavedPhotosAlbum:imageRef orientation:(ALAssetOrientation)self.currentImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
//                        if(error){
//                            TTToast(@"保存失败");
//                            return ;
//                        }else{
//                            TTToast(@"保存成功");
//                        }
//                    }];
//                }
//            }];
//            [actionSheet showInView:[UIWindow topViewController].view];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

