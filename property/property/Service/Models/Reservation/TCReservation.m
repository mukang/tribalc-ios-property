//
//  TCReservation.m
//  individual
//
//  Created by WYH on 16/12/7.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCReservation.h"

@implementation TCReservation

- (void)setStatus:(NSString *)status {
    _status = status;
    if ([status isEqualToString:@"CANCEL"]) {
        self.reservationStatus = TCReservationCancel;
    } else if ([status isEqualToString:@"PROCESSING"]) {
        self.reservationStatus = TCReservationProcessing;
    } else if ([status isEqualToString:@"FAILURE"]) {
        self.reservationStatus = TCReservationFailure;
    } else {
        self.reservationStatus = TCReservationSuccess;
    }
}

@end
