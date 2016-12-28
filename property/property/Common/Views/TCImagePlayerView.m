//
//  TCImagePlayerView.m
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCImagePlayerView.h"
#import "TCImageURLSynthesizer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry.h>

static NSInteger const plusNum = 2;  // 需要加上的数

@interface TCImagePlayerView () <UIScrollViewDelegate>

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation TCImagePlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)dealloc {
    [self removeTimer];
}

- (void)setupSubviews {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.pagingEnabled = YES;
    scrollView.scrollsToTop = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPage = 0;
    pageControl.centerX = self.width * 0.5;
    pageControl.centerY = self.height - 15;
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)setPictures:(NSArray *)pictures {
    _pictures = pictures;
    
    NSInteger imageCount = pictures.count;
    
    if (!imageCount) return;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * (imageCount + plusNum), 0);
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0) animated:NO];
    
    self.pageControl.numberOfPages = imageCount;
    
    for (int i=0; i<imageCount + plusNum; i++) {
        CGFloat imageW = self.scrollView.width;
        CGFloat imageH = self.scrollView.height;
        CGFloat imageX = imageW * i;
        NSInteger imageIndex;
        if (i == 0) {
            imageIndex = imageCount - 1;
        } else if (i == imageCount + 1) {
            imageIndex = 0;
        } else {
            imageIndex = i - 1;
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(imageX, 0, imageW, imageH);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView setTag:imageIndex];
        [imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView:)];
        [imageView addGestureRecognizer:tapGesture];
        [self.scrollView addSubview:imageView];
        
        NSString *URLString = pictures[imageIndex];
        NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:URLString];
        [imageView sd_setImageWithURL:URL placeholderImage:nil options:SDWebImageRetryFailed];
    }
}

#pragma mark - Public Methods

- (void)startPlaying {
    if (!self.isAutoPlayEnabled) return;
    
    if (!self.timer) {
        [self addTimer];
    }
}

- (void)stopPlaying {
    if (!self.isAutoPlayEnabled) return;
    
    [self removeTimer];
}

#pragma mark - Timer

- (void)addTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}

- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Actions

- (void)nextImage {
    
    NSInteger imageCount = self.pictures.count;
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.width;
    
    if (currentPage == 0) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * imageCount, 0) animated:NO];
        currentPage = imageCount - 1;
    } else if (currentPage == imageCount + 1) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0) animated:NO];
        currentPage = 1;
    }
    
    currentPage ++;
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * currentPage, 0) animated:YES];
}

- (void)handleTapImageView:(UITapGestureRecognizer *)sender {
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger imageCount = self.pictures.count;
    NSInteger currentPage = scrollView.contentOffset.x / scrollView.width;
    
    if (currentPage == 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.width * imageCount, 0) animated:NO];
        self.pageControl.currentPage = imageCount - 1;
    } else if (currentPage == imageCount + 1) {
        [scrollView setContentOffset:CGPointMake(scrollView.width, 0) animated:NO];
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = currentPage - 1;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    NSInteger imageCount = self.pictures.count;
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.width;
    
    if (currentPage == imageCount + 1) {
        currentPage = 1;
    }
    
    self.pageControl.currentPage = currentPage - 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopPlaying];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self startPlaying];
}

@end
