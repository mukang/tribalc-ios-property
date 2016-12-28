//
//  TCPropertyRepairsInfo.h
//  individual
//
//  Created by 穆康 on 2016/12/20.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPropertyRepairsInfo : NSObject

/** 楼层 */
@property (copy, nonatomic) NSString *floor;
/** 约定时间 */
@property (nonatomic) NSInteger appointTime;
/** 维修项目(PIPE_FIX,PUBLIC_LIGHTING, WATER_PIPE_FIX, ELECTRICAL_FIX, OTHERS) */
@property (copy, nonatomic) NSString *fixProject;
/** 详细描述 */
@property (copy, nonatomic) NSString *problemDesc;
/** 照片 */
@property (copy, nonatomic) NSArray *pictures;

@end
