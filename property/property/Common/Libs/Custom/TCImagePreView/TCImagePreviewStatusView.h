//
//  TCImagePreviewStatusView.h
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TCImagePreviewStatus) {
    TCImagePreviewStatusNormal = 0,
    TCImagePreviewStatusLoading,
    TCImagePreviewStatusFailed
};

@interface TCImagePreviewStatusView : UIView

@property (nonatomic, assign) TCImagePreviewStatus status;


// 必须要在 dealloc 的时候调用
- (void)clean;

@end
