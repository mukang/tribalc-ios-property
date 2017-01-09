//
//  TCImagePreviewObject.h
//  property
//
//  Created by 王帅锋 on 17/1/9.
//  Copyright © 2017年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 
@interface TCImagePreviewObject : NSObject

@property (nonatomic, strong) NSString* imageUrl;
@property (nonatomic, strong) UIImage* thumbnail;

@end
