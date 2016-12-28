//
//  TCImagePlayerView.h
//  individual
//
//  Created by 穆康 on 2016/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCImagePlayerView : UIView

@property (strong, nonatomic) NSArray *pictures;
/** 是否能自动滚动 */
@property (nonatomic, getter=isAutoPlayEnabled) BOOL autoPlayEnabled;

- (void)startPlaying;
- (void)stopPlaying;

@end
