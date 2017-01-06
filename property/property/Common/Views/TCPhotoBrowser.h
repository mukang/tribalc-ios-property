//
//  TCPhotoBrowser.h
//  individual
//
//  Created by 王帅锋 on 17/1/6.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCPhotoBrowserDelegate <NSObject>

- (void)saveImageWithImage:(UIImage *)img;

@end

@interface TCPhotoBrowser : UIView

@property (nonatomic, strong) NSArray *imgArr;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL isNeedDelete;

@property (nonatomic, assign) CGRect initRect;

@property (nonatomic, copy) void(^deletePhotoAction)(NSInteger);

@property (nonatomic, assign) id<TCPhotoBrowserDelegate> delegate;

@property (nonatomic, assign) BOOL isNeedSave;

@property (nonatomic, assign) BOOL noNeedMoveFrame;
- (void)changeImageViewFrame;
- (void)setInitRect;
@end
