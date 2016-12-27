//
//  UIImage+Category.h
//  individual
//
//  Created by 穆康 on 2016/10/19.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

/**
 *  根据颜色生成一张尺寸为1*1的相同颜色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  根据颜色生成一张尺寸为1*0.5的相同颜色图片(用于阴影线)
 */
+ (UIImage *)shadowImageWithColor:(UIColor *)color;

@end
