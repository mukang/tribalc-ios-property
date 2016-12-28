//
//  TCReservationDetail.h
//  individual
//
//  Created by WYH on 16/12/8.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCReservationDetail : NSObject

@property (copy, nonatomic) NSString *ID;

@property (copy, nonatomic) NSString *status;

@property ( nonatomic) NSInteger personNum;

@property (copy, nonatomic) NSString *storeSetMealId;

@property (copy, nonatomic) NSString *markPlace;

@property (copy, nonatomic) NSString *storeId;

@property (copy, nonatomic) NSString *storeName;

@property ( nonatomic) NSInteger appointTime;

@property (copy, nonatomic) NSArray *tags;

@property (copy, nonatomic) NSString *mainPicture;

@property (copy, nonatomic) NSString *linkman;

@property (copy, nonatomic) NSString *sex;

@property (copy, nonatomic) NSString *phone;

@property (copy, nonatomic) NSString *note;

@property (copy, nonatomic) NSString *address;



@end
