//
//  TCImagePreivewCell.h
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCImagePreviewObject.h"

@interface TCImagePreivewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageContainerView;

@property (nonatomic, weak) TCImagePreviewObject* model;
@property (nonatomic, assign) BOOL showFullImage;

@property (nonatomic, copy) void (^singleTapGestureBlock)(TCImagePreivewCell*);

- (void)recoverSubviews;

+ (CGRect)imageContainerRectWithImage:(UIImage*)image withSize:(CGSize)size;

@end
