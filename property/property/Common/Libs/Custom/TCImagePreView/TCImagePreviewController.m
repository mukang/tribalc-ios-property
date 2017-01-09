//
//  TCImagePreviewController.m
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCImagePreviewController.h"

#import "TCImagePreivewCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TCCustomTransitionAnimation.h"
#import "TCFadeOutTransitionAnimation.h"


@interface TCImagePreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, strong) UIView* pageView;
@property (nonatomic, strong) UILabel* pageLabel;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval lastTimerTick;
@property (nonatomic, assign) CGFloat animationPointsPerSecond;
@property (nonatomic, assign) CGPoint finalContentOffset;
@property (nonatomic, assign) BOOL scrollToLeft;

@end

@implementation TCImagePreviewController
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _minimumLineSpacing = 20;
    [self configCollectionView];
    [self configPageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _collectionView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((self.view.frame.size.width + _minimumLineSpacing) * _currentIndex, 0) animated:NO];
    }
    [self refreshPageView];
    if (_appearWithAnimation) {
        _collectionView.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0 || currentIndex >= _models.count) {
        return;
    }
    _currentIndex = currentIndex;
}

- (void)setModels:(NSMutableArray *)models
{
    NSMutableArray* newModels = [NSMutableArray arrayWithArray:models];
    _models = newModels;
    [_collectionView reloadData];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = _minimumLineSpacing;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TCImagePreivewCell class] forCellWithReuseIdentifier:@"TTImagePreivewCell"];
}

- (void)configPageView
{
    _pageView = [UIView new];
    _pageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    _pageView.layer.cornerRadius = 16;
    [self.view addSubview:_pageView];
    [_pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(32);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(26);
    }];
    
    _pageLabel = [UILabel new];
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    [_pageView addSubview:_pageLabel];
    [_pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(_pageView);
    }];
}

- (void)refreshPageView
{
    _pageView.hidden = _models.count <= 1;
    _pageLabel.text =  [NSString stringWithFormat:@"%ld/%lu",(long)_currentIndex+1,(unsigned long)_models.count];
}

- (id<UIViewControllerAnimatedTransitioning>)fetchTransitionAnimationWithImageUrl:(NSURL*)imageUrl beganRect:(CGRect)begnRect
{
    _appearWithAnimation = NO;
    
    if (!imageUrl) {
        return [TCFadeOutTransitionAnimation new];
    }
    
    __block BOOL isCache = NO;
    
    [[SDWebImageManager sharedManager] cachedImageExistsForURL:imageUrl completion:^(BOOL isInCache) {
        isCache = isInCache;
    }];
    
    if (!isCache) {
        return [TCFadeOutTransitionAnimation new];
    }
    
    NSString* imageCacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:imageUrl];
    UIImage* image = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:imageCacheKey] ?:
    [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:imageCacheKey];
    if (!image) {
        return [TCFadeOutTransitionAnimation new];
    }
    
    TCCustomTransitionAnimation* animation = [TCCustomTransitionAnimation new];
    [animation setupAnimationWithTopImage:image beginRect:begnRect endRect:[TCImagePreivewCell imageContainerRectWithImage:image withSize:self.view.frame.size]];
    animation.endMode = UIViewContentModeScaleToFill;
    _appearWithAnimation = YES;
    return animation;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offSet = scrollView.contentOffset;
    CGFloat offSetWidth = offSet.x;
    if ((offSetWidth + ((self.view.frame.size.width + _minimumLineSpacing) * 0.5)) < scrollView.contentSize.width + _minimumLineSpacing) {
        offSetWidth = offSetWidth +  ((self.view.frame.size.width + _minimumLineSpacing) * 0.5);
    }
    
    NSInteger currentIndex = offSetWidth / (self.view.frame.size.width + _minimumLineSpacing);
    
    if (_currentIndex != currentIndex) {
        self.currentIndex = currentIndex;
        [self refreshPageView];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TCImagePreivewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImagePreivewCell" forIndexPath:indexPath];
    cell.model = _models[indexPath.row];
    @WeakObj(self)
    [cell setSingleTapGestureBlock:^(TCImagePreivewCell *cell) {
        @StrongObj(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if (contentOffsetX < 0 || contentOffsetX > scrollView.contentSize.width - scrollView.frame.size.width) {
        return;
    }
    
    NSInteger MAX_INDEX = (scrollView.contentSize.width + _minimumLineSpacing)/(self.view.frame.size.width + _minimumLineSpacing) - 1;
    NSInteger MIN_INDEX = 0;
    
    NSInteger index = contentOffsetX/(self.view.frame.size.width + _minimumLineSpacing);
    
    if (velocity.x > 0.4 && contentOffsetX < (*targetContentOffset).x) {
        index = index + 1;
    }
    else if (velocity.x < -0.4 && contentOffsetX > (*targetContentOffset).x) {
        index = index;
    }
    else if (contentOffsetX > (index + 0.5) * (self.view.frame.size.width + _minimumLineSpacing)) {
        index = index + 1;
    }
    
    if (index > MAX_INDEX) index = MAX_INDEX;
    if (index < MIN_INDEX) index = MIN_INDEX;
    
    CGPoint newTargetContentOffset= CGPointMake(index * (self.view.frame.size.width + _minimumLineSpacing), 0);
    *targetContentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    [self scrollToPoint:newTargetContentOffset];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TCImagePreivewCell class]]) {
        [(TCImagePreivewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TCImagePreivewCell class]]) {
        [(TCImagePreivewCell *)cell recoverSubviews];
    }
}

#pragma mark - Collection scroll to

-(void)scrollToPoint:(CGPoint) point {
    [self endAnimation];
    self.lastTimerTick = 0;
    self.animationPointsPerSecond = [UIScreen mainScreen].bounds.size.width * 4;
    self.finalContentOffset = point;
    self.scrollToLeft = point.x > _collectionView.contentOffset.x;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
    [self.displayLink setFrameInterval:1];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)endAnimation {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

-(void)displayLinkTick {
    if (self.lastTimerTick == 0) {
        self.lastTimerTick = self.displayLink.timestamp;
        return;
    }
    CFTimeInterval currentTimestamp = self.displayLink.timestamp;
    CGPoint newContentOffset = _collectionView.contentOffset;
    if (_scrollToLeft) {
        newContentOffset.x += self.animationPointsPerSecond * (currentTimestamp - self.lastTimerTick);
        newContentOffset.x = newContentOffset.x > self.finalContentOffset.x ? self.finalContentOffset.x : newContentOffset.x;
    } else {
        newContentOffset.x -= self.animationPointsPerSecond * (currentTimestamp - self.lastTimerTick);
        newContentOffset.x = newContentOffset.x < self.finalContentOffset.x ? self.finalContentOffset.x : newContentOffset.x;
    }
    _collectionView.contentOffset = newContentOffset;
    self.lastTimerTick = currentTimestamp;
    
    if (newContentOffset.x == self.finalContentOffset.x) {
        [self endAnimation];
    }
}

#pragma mark - TTTransitionAnimationSupportDelegate

- (BOOL)isTransitionAnimationSupport
{
    return YES;
}

- (id<UIViewControllerAnimatedTransitioning>)pushTransitionAnimationSupport
{
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)popTransitionAnimationSupport
{
//    if ([TTDeviceInfo iOS8]) {
//        return nil;
//    }
    
    
    TCImagePreivewCell* currentCell = nil;
    
    NSArray* cells = [_collectionView visibleCells];
    for (TCImagePreivewCell* cell in cells) {
        NSIndexPath* index = [_collectionView indexPathForCell:cell];
        if (index.row == _currentIndex) {
            currentCell = cell;
            break;
        }
    }
    
    if (!currentCell) {
        return nil;
    }
    UIImage* image = currentCell.imageView.image;
    if (currentCell.showFullImage && _delegate && !(image.size.width/image.size.height >= 4 || image.size.height/image.size.width >= 4 )) {
        TCCustomTransitionAnimation* animation = [TCCustomTransitionAnimation new];
        [animation setupAnimationWithTopImage:currentCell.imageView.image beginRect:currentCell.imageContainerView.frame endRect:[_delegate transitionAnimationImageEndRectWithIndex:_currentIndex]];
        animation.beganMode = UIViewContentModeScaleToFill;
        return animation;
    } else {
        return [TCFadeOutTransitionAnimation new];
    }
}

- (void)dealloc {
    TCLog(@"TCImagePreviewController -- dealloc");
}

@end

