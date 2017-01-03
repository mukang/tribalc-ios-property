//
//  TCBuluoApi.m
//  individual
//
//  Created by 穆康 on 2016/11/3.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBuluoApi.h"
#import "TCClient.h"
#import "TCArchiveService.h"

#import "NSObject+TCModel.h"

NSString *const TCBuluoApiNotificationUserDidLogin = @"TCBuluoApiNotificationUserDidLogin";
NSString *const TCBuluoApiNotificationUserDidLogout = @"TCBuluoApiNotificationUserDidLogout";
NSString *const TCBuluoApiNotificationUserInfoDidUpdate = @"TCBuluoApiNotificationUserInfoDidUpdate";

@implementation TCBuluoApi {
    TCUserSession *_userSession;
}

+ (instancetype)api {
    static TCBuluoApi *api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api = [[self class] new];
        [api loadArchivedUserSession];
    });
    return api;
}
//
//#pragma mark - 设备相关
//
//- (void)prepareForWorking:(void (^)(NSError *))completion {
//    _prepared = YES;
//    
//    if (completion) {
//        completion(nil);
//    }
//}
//
#pragma mark - 用户会话相关

- (void)loadArchivedUserSession {
    NSString *sessionModelName = NSStringFromClass([TCUserSession class]);
    TCArchiveService *archiveService = [TCArchiveService sharedService];
    TCUserSession *session = [archiveService unarchiveObject:sessionModelName
                                                forLoginUser:nil
                                                 inDirectory:TCArchiveDocumentDirectory];
    _userSession = session;
}

- (BOOL)isUserSessionValid {
    if (_userSession) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)needLogin {
    return ![self isUserSessionValid];
}

- (TCUserSession *)currentUserSession {
    if ([self isUserSessionValid]) {
        return _userSession;
    } else {
        return nil;
    }
}

- (void)setUserSession:(TCUserSession *)userSession {
    _userSession = userSession;
    if (userSession) {
        BOOL success = [[TCArchiveService sharedService] archiveObject:userSession
                                                          forLoginUser:nil
                                                           inDirectory:TCArchiveDocumentDirectory];
        if (success) {
            TCLog(@"UserSession归档成功");
        } else {
            TCLog(@"UserSession归档失败");
        }
    }
}

- (void)cleanUserSession {
    if (_userSession) {
        _userSession = nil;
    }
    BOOL success = [[TCArchiveService sharedService] cleanObject:NSStringFromClass([TCUserSession class])
                                                    forLoginUser:nil
                                                     inDirectory:TCArchiveDocumentDirectory];
    if (success) {
        TCLog(@"UserSession清除成功");
    } else {
        TCLog(@"UserSession清除失败");
    }
}

- (void)fetchCurrentUserInfoWithUserID:(NSString *)userID {
    [self fetchUserInfoWithUserID:userID result:^(TCUserInfo *userInfo, NSError *error) {
        if (userInfo) {
            TCUserSession *userSession = self.currentUserSession;
            userSession.userInfo = userInfo;
            [self setUserSession:userSession];
            [[NSNotificationCenter defaultCenter] postNotificationName:TCBuluoApiNotificationUserInfoDidUpdate object:nil];
        }
    }];
}

- (void)fetchCurrentUserSensitiveInfoWithUserID:(NSString *)userID {
    [self fetchUserSensitiveInfoWithUserID:userID result:^(TCUserSensitiveInfo *userSensitiveInfo, NSError *error) {
        if (userSensitiveInfo) {
            TCUserSession *userSession = self.currentUserSession;
            userSession.userSensitiveInfo = userSensitiveInfo;
            [self setUserSession:userSession];
            if (userSensitiveInfo.addressID) {
                [self fetchUserDefaultShippingAddressWithAddressID:userSensitiveInfo.addressID];
            }
        }
    }];
}

- (void)fetchUserDefaultShippingAddressWithAddressID:(NSString *)addressID {
    [self fetchUserShippingAddress:addressID result:^(TCUserShippingAddress *shippingAddress, NSError *error) {
        if (shippingAddress) {
            TCUserSession *userSession = self.currentUserSession;
            userSession.userSensitiveInfo.shippingAddress = shippingAddress;
            [self setUserSession:userSession];
        }
    }];
}

#pragma mark - 普通用户资源

- (void)login:(TCUserPhoneInfo *)phoneInfo result:(void (^)(TCUserSession *, NSError *))resultBlock {
    NSString *apiName = @"property_members/login";
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
    NSDictionary *dic = [phoneInfo toObjectDictionary];
    for (NSString *key in dic.allKeys) {
        [request setValue:dic[key] forParam:key];
    }
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        TCUserSession *userSession = nil;
        NSError *error = response.error;
        if (error) {
            [self setUserSession:nil];
        } else {
            userSession = [[TCUserSession alloc] initWithObjectDictionary:response.data];
            [self setUserSession:userSession];
            [self fetchCurrentUserInfoWithUserID:userSession.assigned];
//            [self fetchCurrentUserSensitiveInfoWithUserID:userSession.assigned];
            TC_CALL_ASYNC_MQ({
                [[NSNotificationCenter defaultCenter] postNotificationName:TCBuluoApiNotificationUserDidLogin object:nil];
            });
        }
        if (resultBlock) {
            if (error) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, error));
            } else {
                TC_CALL_ASYNC_MQ(resultBlock(userSession, nil));
            }
        }
    }];
}

- (void)logout:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
        }
    } else {
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
        }
    }
    [self cleanUserSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:TCBuluoApiNotificationUserDidLogout object:nil];
}

- (void)fetchUserInfoWithUserID:(NSString *)userID result:(void (^)(TCUserInfo *, NSError *))resultBlock {
    NSString *apiName = [NSString stringWithFormat:@"%@", userID];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        NSError *error = response.error;
        if (error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, error));
            }
        } else {
            TCUserInfo *userInfo = [[TCUserInfo alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(userInfo, nil));
            }
        }
    }];
}

- (void)fetchUserSensitiveInfoWithUserID:(NSString *)userID result:(void (^)(TCUserSensitiveInfo *, NSError *))resultBlock {
    NSString *apiName = [NSString stringWithFormat:@"persons/%@/sensitive_info", userID];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        NSError *error = response.error;
        if (error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, error));
            }
        } else {
            TCUserSensitiveInfo *info = [[TCUserSensitiveInfo alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(info, nil));
            }
        }
    }];
}

- (void)changeUserNickname:(NSString *)nickname result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/nickname", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [request setValue:nickname forParam:@"nickname"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
                userSession.userInfo.nickname = nickname;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)changeUserAvatar:(NSString *)avatar result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/picture", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [request setValue:avatar forParam:@"picture"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
//                userSession.userInfo.picture = avatar;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)changeUserCover:(NSString *)cover result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/cover", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [request setValue:cover forParam:@"cover"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
//                userSession.userInfo.cover = cover;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)changeUserGender:(TCUserGender)gender result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/sex", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        NSString *sex = @"UNKNOWN";
        switch (gender) {
            case TCUserGenderMale:
                sex = @"MALE";
                break;
            case TCUserGenderFemale:
                sex = @"FEMALE";
                break;
            default:
                break;
        }
        [request setValue:sex forParam:@"sex"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
                userSession.userInfo.sex = sex;
                userSession.userInfo.gender = gender;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)changeUserBirthdate:(NSDate *)birthdate result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/birthday", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        NSTimeInterval timestamp = [birthdate timeIntervalSince1970];
        [request setValue:[NSNumber numberWithInteger:(timestamp * 1000)] forParam:@"birthday"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
                userSession.userInfo.birthday = (NSUInteger)(timestamp * 1000);
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)changeUserEmotionState:(TCUserEmotionState)emotionState result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/emotion", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        NSString *emotion = @"UNKNOWN";
        switch (emotionState) {
            case TCUserEmotionStateMarried:
                emotion = @"MARRIED";
                break;
            case TCUserEmotionStateSingle:
                emotion = @"SINGLE";
                break;
            case TCUserEmotionStateLove:
                emotion = @"LOVE";
                break;
            default:
                break;
        }
        [request setValue:emotion forKey:@"emotion"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
                userSession.userInfo.emotion = emotion;
                userSession.userInfo.emotionState = emotionState;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

//- (void)changeUserAddress:(TCUserAddress *)userAddress result:(void (^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/province,city,district", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
//        NSDictionary *dic = [userAddress toObjectDictionary];
//        for (NSString *key in dic.allKeys) {
//            [request setValue:dic[key] forParam:key];
//        }
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                TCUserSession *userSession = self.currentUserSession;
//                userSession.userInfo.province = userAddress.province;
//                userSession.userInfo.city = userAddress.city;
//                userSession.userInfo.district = userAddress.district;
//                [self setUserSession:userSession];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//}
//
//- (void)changeUserCoordinate:(NSArray *)coordinate result:(void (^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/coordinate", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
//        [request setValue:coordinate forParam:@"coordinate"];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                TCUserSession *userSession = self.currentUserSession;
//                userSession.userInfo.coordinate = coordinate;
//                [self setUserSession:userSession];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//}

- (void)changeUserPhone:(TCUserPhoneInfo *)phoneInfo result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/sensitive_info/phone", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        NSDictionary *dic = [phoneInfo toObjectDictionary];
        for (NSString *key in dic.allKeys) {
            [request setValue:dic[key] forParam:key];
        }
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
                userSession.userSensitiveInfo.phone = phoneInfo.phone;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)setUserDefaultShippingAddress:(TCUserShippingAddress *)shippingAddress result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/sensitive_info/addressID", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [request setValue:shippingAddress.ID forKey:@"value"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSession *userSession = self.currentUserSession;
                userSession.userSensitiveInfo.addressID = shippingAddress.ID;
                userSession.userSensitiveInfo.shippingAddress = shippingAddress;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)addUserShippingAddress:(TCUserShippingAddress *)shippingAddress result:(void (^)(BOOL, TCUserShippingAddress *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/addresses", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
        NSDictionary *dic = [shippingAddress toObjectDictionary];
        for (NSString *key in dic.allKeys) {
            [request setValue:dic[key] forParam:key];
        }
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 201) {
                TCUserShippingAddress *address = [[TCUserShippingAddress alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, address, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, nil, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, nil, sessionError));
        }
    }
}

- (void)fetchUserShippingAddressList:(void (^)(NSArray *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/addresses", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            NSError *error = response.error;
            if (error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, error));
                }
            } else {
                NSMutableArray *addressList = [NSMutableArray array];
                NSArray *dics = response.data;
                for (NSDictionary *dic in dics) {
                    TCUserShippingAddress *address = [[TCUserShippingAddress alloc] initWithObjectDictionary:dic];
                    [addressList addObject:address];
                }
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock([addressList copy], nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)fetchUserShippingAddress:(NSString *)shippingAddressID result:(void (^)(TCUserShippingAddress *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/addresses/%@", self.currentUserSession.assigned, shippingAddressID];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCUserShippingAddress *address = [[TCUserShippingAddress alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(address, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)changeUserShippingAddress:(TCUserShippingAddress *)shippingAddress result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/addresses/%@", self.currentUserSession.assigned, shippingAddress.ID];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        NSDictionary *dic = [shippingAddress toObjectDictionary];
        for (NSString *key in dic.allKeys) {
            [request setValue:dic[key] forParam:key];
        }
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                if ([shippingAddress.ID isEqualToString:self.currentUserSession.userSensitiveInfo.addressID]) {
                    TCUserSession *userSession = self.currentUserSession;
                    userSession.userSensitiveInfo.shippingAddress = shippingAddress;
                    [self setUserSession:userSession];
                }
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

//- (void)deleteUserShippingAddress:(NSString *)shippingAddressID result:(void (^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/addresses/%@", self.currentUserSession.assigned, shippingAddressID];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodDelete apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 204) {
//                if ([shippingAddressID isEqualToString:self.currentUserSession.userSensitiveInfo.addressID]) {
//                    TCUserSession *userSession = [self currentUserSession];
//                    userSession.userSensitiveInfo.addressID = nil;
//                    userSession.userSensitiveInfo.shippingAddress = nil;
//                    [self setUserSession:userSession];
//                }
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//}
//
//- (void)fetchWalletAccountInfo:(void (^)(TCWalletAccount *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/wallet", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.error) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            } else {
//                TCWalletAccount *walletAccount = [[TCWalletAccount alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(walletAccount, nil));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}

- (void)fetchWalletBillWrapper:(NSString *)tradingType count:(NSUInteger)count sortSkip:(NSString *)sortSkip result:(void (^)(TCWalletBillWrapper *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *tradingTypePart = tradingType ? [NSString stringWithFormat:@"tradingType=%@&", tradingType] : @"";
        NSString *limitSizePart = [NSString stringWithFormat:@"limitSize=%zd", count];
        NSString *sortSkipPart = sortSkip ? [NSString stringWithFormat:@"&sortSkip=%@", sortSkip] : @"";
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/bills?%@%@%@", self.currentUserSession.assigned, tradingTypePart, limitSizePart, sortSkipPart];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCWalletBillWrapper *walletBillWrapper = [[TCWalletBillWrapper alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(walletBillWrapper, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)changeWalletPassword:(NSString *)messageCode anOldPassword:(NSString *)anOldPassword aNewPassword:(NSString *)aNewPassword result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName;
        if (messageCode) {
            apiName = [NSString stringWithFormat:@"persons/%@/wallet/password?vcode=%@", self.currentUserSession.assigned, messageCode];
        } else {
            apiName = [NSString stringWithFormat:@"persons/%@/wallet/password", self.currentUserSession.assigned];
        }
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [request setValue:anOldPassword forParam:@"oldPassword"];
        [request setValue:aNewPassword forParam:@"newPassword"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

//- (void)fetchBankCardList:(void (^)(NSArray *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/bank_cards", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.error) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            } else {
//                NSMutableArray *bankCardList = [NSMutableArray array];
//                NSArray *dics = response.data;
//                for (NSDictionary *dic in dics) {
//                    TCBankCard *bankCard = [[TCBankCard alloc] initWithObjectDictionary:dic];
//                    [bankCardList addObject:bankCard];
//                }
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock([bankCardList copy], nil));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}

- (void)addBankCard:(TCBankCard *)bankCard withVerificationCode:(NSString *)verificationCode result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/bank_cards?vcode=%@", self.currentUserSession.assigned, verificationCode];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
        NSDictionary *dic = [bankCard toObjectDictionary];
        for (NSString *key in dic.allKeys) {
            [request setValue:dic[key] forParam:key];
        }
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 201) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

//- (void)deleteBankCard:(NSString *)bankCardID result:(void (^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/bank_cards/%@", self.currentUserSession.assigned, bankCardID];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodDelete apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 204) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//}

- (void)fetchCompanyBlindStatus:(void (^)(TCUserCompanyInfo *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/company_bind_request", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCUserCompanyInfo *userCompanyInfo = [[TCUserCompanyInfo alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(userCompanyInfo, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)bindCompanyWithUserCompanyInfo:(TCUserCompanyInfo *)userCompanyInfo result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/company_bind_request", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
        [request setValue:userCompanyInfo.company.ID forParam:@"companyId"];
        [request setValue:userCompanyInfo.department forParam:@"department"];
        [request setValue:userCompanyInfo.position forParam:@"position"];
        [request setValue:userCompanyInfo.personNum forParam:@"personNum"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 201) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)authorizeUserIdentity:(TCUserIDAuthInfo *)userIDAuthInfo result:(void (^)(TCUserSensitiveInfo *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/authentication", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
        NSDictionary *dic = [userIDAuthInfo toObjectDictionary];
        for (NSString *key in dic.allKeys) {
            [request setValue:dic[key] forParam:key];
        }
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                TCUserSensitiveInfo *sensitiveInfo = [[TCUserSensitiveInfo alloc] initWithObjectDictionary:response.data];
                TCUserSession *userSession = self.currentUserSession;
                userSession.userSensitiveInfo = sensitiveInfo;
                [self setUserSession:userSession];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(sensitiveInfo, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

//- (void)reserveCommunity:(TCCommunityReservationInfo *)communityReservationInfo result:(void (^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/community_reservation", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
//        NSDictionary *dic = [communityReservationInfo toObjectDictionary];
//        for (NSString *key in dic.allKeys) {
//            [request setValue:dic[key] forParam:key];
//        }
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 201) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//}
//
//- (void)commitPaymentWithPayChannel:(TCPayChannel)payChannel orderIDs:(NSArray *)orderIDs result:(void (^)(TCUserPayment *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/payments", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
//        switch (payChannel) {
//            case TCPayChannelBalance:
//                [request setValue:@"BALANCE" forParam:@"payChannel"];
//                break;
//                
//            default:
//                break;
//        }
//        [request setValue:orderIDs forParam:@"orderIds"];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                TCUserPayment *payment = [[TCUserPayment alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(payment, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}
//
//- (void)fetchUserPayment:(NSString *)paymentID result:(void (^)(TCUserPayment *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/payments/%@", self.currentUserSession.assigned, paymentID];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                TCUserPayment *payment = [[TCUserPayment alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(payment, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}
//
#pragma mark - 验证码资源

- (void)fetchVerificationCodeWithPhone:(NSString *)phone result:(void (^)(BOOL, NSError *))resultBlock {
    NSString *apiName = @"verifications/phone";
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
    [request setValue:phone forParam:@"value"];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.statusCode == 202) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
            }
        } else {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
            }
        }
    }];
}

- (void)authorizeImageData:(NSData *)imageData result:(void (^)(TCUploadInfo *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"oss_authorization/picture?me=%@", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
        [request setValue:@"iOS_image.jpg" forParam:@"key"];
        [request setValue:@"image/jpeg" forParam:@"contentType"];
        [request setValue:TCDigestMD5ToData(imageData) forParam:@"contentMD5"];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCUploadInfo *uploadInfo = [[TCUploadInfo alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(uploadInfo, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

////- (void)ossAuthorizeImageData:(NSData *)imageData result:(void (^)(TCOSSParams *, NSError *))resultBlock {
////    if ([self isUserSessionValid]) {
////        NSString *apiName = [NSString stringWithFormat:@"oss_authorization/picture?me=%@", self.currentUserSession.assigned];
////        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
////        [request setValue:@"icon.jpg" forParam:@"key"];
////        [request setValue:@"image/jpeg" forParam:@"contentType"];
////        [request setValue:[OSSUtil base64Md5ForData:imageData] forParam:@"contentMD5"];
////        [[TCClient client] send:request finish:^(TCClientResponse *response) {
////            if (response.error) {
////                if (resultBlock) {
////                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
////                }
////            } else {
////                TCOSSParams *params = [[TCOSSParams alloc] initWithObjectDictionary:response.data];
////                if (resultBlock) {
////                    TC_CALL_ASYNC_MQ(resultBlock(params, nil));
////                }
////            }
////        }];
////    } else {
////        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
////        if (resultBlock) {
////            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
////        }
////    }
////}
//
//#pragma mark - 商品类资源

- (void)fetchGoodsWrapper:(NSUInteger)limitSize sortSkip:(NSString *)sortSkip result:(void (^)(TCGoodsWrapper *, NSError *))resultBlock {
    NSString *limitSizePart = [NSString stringWithFormat:@"limitSize=%zd", limitSize];
    NSString *sortSkipPart = sortSkip ? [NSString stringWithFormat:@"&sortSkip=%@", sortSkip] : @"";
    NSString *apiName = [NSString stringWithFormat:@"goods?%@%@", limitSizePart, sortSkipPart];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
            }
        } else {
            TCGoodsWrapper *goodsWrapper = [[TCGoodsWrapper alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(goodsWrapper, nil));
            }
        }
    }];
}

- (void)fetchGoodDetail:(NSString *)goodsID result:(void (^)(TCGoodDetail *, NSError *))resultBlock {
    NSString *apiName = [NSString stringWithFormat:@"goods/%@", goodsID];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
            }
        } else {
            
            TCGoodDetail *goodDetail = [[TCGoodDetail alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(goodDetail, nil));
            }
        }
    }];
}

- (void)fetchGoodStandards:(NSString *)goodStandardId result:(void (^)(TCGoodStandards *, NSError *))resultBlock {
    NSString *apiName = [NSString stringWithFormat:@"goods_standards/%@", goodStandardId];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
            }
        } else {
            TCGoodStandards *goodStandard = [[TCGoodStandards alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(goodStandard, nil));
            }
        }
    }];
}



#pragma mark - 服务类资源
- (void)fetchServiceWrapper:(NSString *)category limiSize:(NSUInteger)limitSize sortSkip:(NSString *)sortSkip sort:(NSString *)sort result:(void (^)(TCServiceWrapper *, NSError *))resultBlock {
    NSString *sortPart = sort ? [NSString stringWithFormat:@"sort=%@", sort] : @"sort=popularValue,desc";
    NSString *categoryPart = category ? [NSString stringWithFormat:@"category=%@&", category] : @"";
    NSString *limitSizePart = [NSString stringWithFormat:@"limitSize=%zd&", limitSize];
    NSString *sortSkipPart = sortSkip ? [NSString stringWithFormat:@"sortSkip=%@&", sortSkip] : @"";
    NSString *apiName = [NSString stringWithFormat:@"store_set_meals?%@%@%@%@", categoryPart, limitSizePart, sortSkipPart, sortPart];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
            }
        } else {
            TCServiceWrapper *serviceWrapper = [[TCServiceWrapper alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(serviceWrapper, nil));
            }
        }
    }];
}

- (void)fetchServiceDetail:(NSString *)serviceID result:(void (^)(TCServiceDetail *, NSError *))resultBlock {
    NSString *apiName = [NSString stringWithFormat:@"store_set_meals/%@", serviceID];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
            }
        } else {
            TCServiceDetail *serviceDetail = [[TCServiceDetail alloc] initWithObjectDictionary:response.data];
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(serviceDetail, nil));
            }
        }
    }];
}

//#pragma mark - 订单类资源
//- (void)fetchOrderWrapper:(NSString *)status limiSize:(NSUInteger)limitSize sortSkip:(NSString *)sortSkip result:(void (^)(TCOrderWrapper *, NSError *))resultBlock {
//
//    if ([self isUserSessionValid]) {
//        NSString *statusPart = status ? [NSString stringWithFormat:@"&status=%@", status] : @"";
//        NSString *limitSizePart = limitSize ? [NSString stringWithFormat:@"&limitSize=%lu", (unsigned long)limitSize] : @"";
//        NSString *sortSkipPart = sortSkip ? [NSString stringWithFormat:@"&sortSkip=%@", sortSkip] : @"";
//        NSString *apiName = [NSString stringWithFormat:@"orders?type=owner&me=%@%@%@%@", self.currentUserSession.assigned, statusPart, limitSizePart, sortSkipPart];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.error) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            } else {
//                TCOrderWrapper *orderWrapper = [[TCOrderWrapper alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(orderWrapper, nil));
//                }
//            }
//        }];
//    }else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}
//
//- (void)createOrderWithItemList:(NSArray *)itemList AddressId:(NSString *)addressId result:(void(^)(NSArray *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"orders?me=%@", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
//
//        [request setValue:addressId forParam:@"addressId"];
//        [request setValue:itemList forParam:@"itemList"];
//        
//        
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                NSArray *result = response.data;
//                NSMutableArray *orderList = [[NSMutableArray alloc] init];
//                for (int i = 0; i < result.count; i++) {
//                    TCOrder *order = [[TCOrder alloc] initWithObjectDictionary:result[i]];
//                    [orderList addObject:order];
//                }
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock([orderList copy], nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            }
//        }];
//    }  else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}
//
//- (void)changeOrderStatus:(NSString *)statusStr OrderId:(NSString *)orderId result:(void(^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"orders/%@/status?type=owner&me=%@", orderId, self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
//        [request setValue:statusStr forParam:@"value"];
//        [[TCClient client] send:request finish:^(TCClientResponse *respone) {
//            if (respone.statusCode == 200) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, respone.error));
//                }
//            }
//        }];
//    }  else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//}
//
//
//
//
//#pragma mark - 服务预订资源
//- (void)fetchReservationWrapper:(NSString *)status limiSize:(NSUInteger)limitSize sortSkip:(NSString *)sortSkip result:(void (^)(TCReservationWrapper *, NSError *))resultBlock {
//    
//    if ([self isUserSessionValid]) {
//        NSString *statusPart = status ? [NSString stringWithFormat:@"&status=%@", status] : @"";
//        NSString *limitSizePart = limitSize ? [NSString stringWithFormat:@"&limitSize=%lu", (unsigned long)limitSize] : @"";
//        NSString *sortSkipPart = sortSkip ? [NSString stringWithFormat:@"&sortSkip=%@", sortSkip] : @"";
//        NSString *apiName = [NSString stringWithFormat:@"reservations?type=owner&me=%@%@%@%@", self.currentUserSession.assigned, statusPart, limitSizePart, sortSkipPart];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.error) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            } else {
//                TCReservationWrapper *orderWrapper = [[TCReservationWrapper alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(orderWrapper, nil));
//                }
//            }
//        }];
//    }else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}

- (void)fetchReservationDetail:(NSString *)reserveID result:(void (^)(TCReservationDetail *, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"reservations/%@?type=owner&me=%@", reserveID, [self currentUserSession].assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCReservationDetail *reservationDetail = [[TCReservationDetail alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(reservationDetail, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)changeReservationStatus:(NSString *)statusStr ReservationId:(NSString *)reservationId result:(void(^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"reservations/%@/status?type=owner&me=%@", reservationId, self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [request setValue:@"CANCEL" forParam:@"value"];
        
        [[TCClient client] send:request finish:^(TCClientResponse *respone) {
            if (respone.statusCode == 200) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, respone.error));
                }
            }
        }];
    }  else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}


//- (void)createReservationWithStoreSetMealId:(NSString *)storeSetMealId appintTime:(NSInteger)appintTime personNum:(NSInteger)personNum linkman:(NSString *)linkman phone:(NSString *)phone note:(NSString *)note vcode:(NSString *)vcode result:(void(^)(TCReservationDetail *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        
//        NSString *vcodeStr = vcode ? [NSString stringWithFormat:@"&vcode=%@", vcode] : @"";
//        NSString *apiName = [NSString stringWithFormat:@"reservations?me=%@%@", self.currentUserSession.assigned, vcodeStr];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
//        
//        [request setValue:storeSetMealId forParam:@"storeSetMealId"];
//        [request setValue:[NSNumber numberWithInteger:appintTime] forParam:@"appintTime"];
//        [request setValue:[NSNumber numberWithInteger:personNum] forParam:@"personNum"];
//        [request setValue:linkman forParam:@"linkman"];
//        [request setValue:phone forParam:@"phone"];
//        [request setValue:note forParam:@"note"];
//        
//        [[TCClient client] send:request finish:^(TCClientResponse *respone) {
//            TCReservationDetail *result = [[TCReservationDetail alloc] initWithObjectDictionary:respone.data];
//            if (respone.statusCode == 201) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(result, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, respone.error));
//                }
//            }
//        }];
//    }  else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}
//
//
//#pragma mark - 购物车资源
//- (void)fetchShoppingCartWrapperWithSortSkip:(NSString *)sortSkip result:(void (^)(TCShoppingCartWrapper *, NSError *))resultBlock {
//    
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/shopping_cart?limitSize=50", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.error) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//                }
//            } else {
//                TCShoppingCartWrapper *shoppingWrapper = [[TCShoppingCartWrapper alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(shoppingWrapper, nil));
//                }
//            }
//        }];
//    }else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//}

- (void)createShoppingCartWithAmount:(NSInteger)amount goodsId:(NSString *)goodsId result:(void(^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"persons/%@/shopping_cart", self.currentUserSession.assigned];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
        
        [request setValue:[NSNumber numberWithInteger:amount] forParam:@"amount"];
        [request setValue:goodsId forParam:@"goodsId"];
        
        [[TCClient client] send:request finish:^(TCClientResponse *respone) {
            if (respone.statusCode == 201) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, respone.error));
                }
            }
        }];
    }  else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

//- (void)changeShoppingCartWithShoppingCartGoodsId:(NSString *)shoppingCartGoodsId AndNewGoodsId:(NSString *)newGoodsId AndAmount:(NSInteger)amount result:(void(^)(TCCartItem *, NSError *))resultBlock{
//    if ([self isUserSessionValid]) {
//
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/shopping_cart", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
//        [request setValue:shoppingCartGoodsId forParam:@"shoppingCartGoodsId"];
//        [request setValue:newGoodsId forParam:@"newGoodsId"];
//        [request setValue:[NSNumber numberWithInteger:amount] forParam:@"amount"];
//        
//        [[TCClient client ] send:request finish:^(TCClientResponse *respone) {
//            if (respone.statusCode == 200) {
//                TCCartItem *result = [[TCCartItem alloc] initWithObjectDictionary:respone.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(result, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(nil, respone.error));
//                }
//            }
//        }];
//    }  else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
//        }
//    }
//
//}
//
//- (void)deleteShoppingCartWithShoppingCartArr:(NSArray *)cartArr result:(void(^)(BOOL, NSError *))resultBlock{
//    if ([self isUserSessionValid]) {
//        
//        NSString *shoppingCartGoodIdStr = @"";
//        for (int i = 0; i < cartArr.count; i++) {
//            shoppingCartGoodIdStr = (i == 0) ? [NSString stringWithFormat:@"/%@", cartArr[i]] : [NSString stringWithFormat:@"%@,%@", shoppingCartGoodIdStr, cartArr[i]];
//        }
//        
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/shopping_cart%@", self.currentUserSession.assigned, shoppingCartGoodIdStr];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodDelete apiName:apiName];
//        
//        [[TCClient client] send:request finish:^(TCClientResponse *respone) {
//            if (respone.statusCode == 204) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, respone.error));
//                }
//            }
//        }];
//    }  else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//        }
//    }
//    
//}



#pragma mark - 上传图片资源

- (void)uploadImage:(UIImage *)image progress:(void (^)(NSProgress *))progress result:(void (^)(BOOL, TCUploadInfo *, NSError *))resultBlock {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [self authorizeImageData:imageData result:^(TCUploadInfo *uploadInfo, NSError *error) {
        if (error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(NO, nil, error));
            }
        } else {
            NSString *uploadURLString = uploadInfo.url;
            TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut uploadURLString:uploadURLString];
            [request setImageData:imageData];
            [[TCClient client] upload:request progress:progress finish:^(TCClientResponse *response) {
                if (response.statusCode == 200) {
                    if (resultBlock) {
                        TC_CALL_ASYNC_MQ(resultBlock(YES, uploadInfo, nil));
                    }
                } else {
                    if (resultBlock) {
                        TC_CALL_ASYNC_MQ(resultBlock(NO, nil, response.error));
                    }
                }
            }];
        }
    }];
}

//#pragma mark - 社区资源
//
//- (void)fetchCommunityList:(void (^)(NSArray *, NSError *))resultBlock {
//    NSString *apiName = @"communities";
//    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//    [[TCClient client] send:request finish:^(TCClientResponse *response) {
//        if (response.error) {
//            if (resultBlock) {
//                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//            }
//        } else {
//            NSMutableArray *communityList = [NSMutableArray array];
//            NSArray *dics = response.data;
//            for (NSDictionary *dic in dics) {
//                TCCommunity *community = [[TCCommunity alloc] initWithObjectDictionary:dic];
//                [communityList addObject:community];
//            }
//            if (resultBlock) {
//                TC_CALL_ASYNC_MQ(resultBlock([communityList copy], nil));
//            }
//        }
//    }];
//}
//
//- (void)fetchCommunityDetailInfo:(NSString *)communityID result:(void (^)(TCCommunityDetailInfo *, NSError *))resultBlock {
//    NSString *apiName = [NSString stringWithFormat:@"communities/%@", communityID];
//    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//    [[TCClient client] send:request finish:^(TCClientResponse *response) {
//        if (response.error) {
//            if (resultBlock) {
//                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//            }
//        } else {
//            TCCommunityDetailInfo *communityDetailInfo = [[TCCommunityDetailInfo alloc] initWithObjectDictionary:response.data];
//            if (resultBlock) {
//                TC_CALL_ASYNC_MQ(resultBlock(communityDetailInfo, nil));
//            }
//        }
//    }];
//}
//
//- (void)fetchCommunityListGroupByCity:(void (^)(NSArray *, NSError *))resultBlock {
//    NSString *apiName = @"communities/property_management";
//    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
//    [[TCClient client] send:request finish:^(TCClientResponse *response) {
//        if (response.error) {
//            if (resultBlock) {
//                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
//            }
//        } else {
//            NSMutableArray *communities = [NSMutableArray array];
//            NSDictionary *dic = response.data;
//            for (NSString *key in dic.allKeys) {
//                NSMutableArray *communityList = [NSMutableArray array];
//                for (NSDictionary *communityDic in dic[key]) {
//                    TCCommunity *community = [[TCCommunity alloc] initWithObjectDictionary:communityDic];
//                    [communityList addObject:community];
//                }
//                TCCommunityListInCity *communityListInCity = [[TCCommunityListInCity alloc] init];
//                communityListInCity.city = key;
//                communityListInCity.communityList = [communityList copy];
//                [communities addObject:communityListInCity];
//            }
//            if (resultBlock) {
//                TC_CALL_ASYNC_MQ(resultBlock([communities copy], nil));
//            }
//        }
//    }];
//}

#pragma mark - 公司资源

- (void)fetchCompanyList:(NSString *)communityID result:(void (^)(NSArray *, NSError *))resultBlock {
    NSString *apiName = [NSString stringWithFormat:@"companies?communityId=%@", communityID];
    TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
    [[TCClient client] send:request finish:^(TCClientResponse *response) {
        if (response.error) {
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
            }
        } else {
            NSMutableArray *companyList = [NSMutableArray array];
            NSArray *dicArray = response.data;
            for (NSDictionary *dic in dicArray) {
                TCCompanyInfo *companyInfo = [[TCCompanyInfo alloc] initWithObjectDictionary:dic];
                [companyList addObject:companyInfo];
            }
            if (resultBlock) {
                TC_CALL_ASYNC_MQ(resultBlock([companyList copy], nil));
            }
        }
    }];
}
#pragma mark - 物业报修

- (void)fetchPropertyWrapper:(NSString *)status count:(NSUInteger)count sortSkip:(NSString *)sortSkip result:(void (^)(TCPropertyManageWrapper *propertyManageWrapper, NSError *error))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *s = status ? [NSString stringWithFormat:@"displayStatus=%@&", status] : @"";
        NSString *limitSizePart = [NSString stringWithFormat:@"limitSize=%zd", count];
        NSString *sortSkipPart = sortSkip ? [NSString stringWithFormat:@"&sortSkip=%@", sortSkip] : @"";
        NSString *apiName = [NSString stringWithFormat:@"property_orders?type=property&staff=%@&%@%@%@", self.currentUserSession.assigned, s, limitSizePart, sortSkipPart];
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/property_management?%@%@%@", @"5824287f0cf210fc9cef5e42", s, limitSizePart, sortSkipPart];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCPropertyManageWrapper *propertyManageWrapper = [[TCPropertyManageWrapper alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(propertyManageWrapper, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

//- (void)commitPropertyRepairsInfo:(TCPropertyRepairsInfo *)repairsInfo result:(void (^)(BOOL, TCPropertyManage *, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/property_management", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
//        NSDictionary *dic = [repairsInfo toObjectDictionary];
//        for (NSString *key in dic.allKeys) {
//            [request setValue:dic[key] forParam:key];
//        }
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                TCPropertyManage *propertyManage = [[TCPropertyManage alloc] initWithObjectDictionary:response.data];
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, propertyManage, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, nil, response.error));
//                }
//            }
//        }];
//    } else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, nil, sessionError));
//
//        }
//    }
//}
//
//#pragma 手机开锁
//- (void)openDoorWithResult:(void (^)(BOOL, NSError *))resultBlock {
//    if ([self isUserSessionValid]) {
//        NSString *apiName = [NSString stringWithFormat:@"persons/%@/unlock_door?", self.currentUserSession.assigned];
//        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPost apiName:apiName];
//        [request setValue:@"ssssss" forParam:@"value"];
//        [[TCClient client] send:request finish:^(TCClientResponse *response) {
//            if (response.statusCode == 200) {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
//                }
//            } else {
//                if (resultBlock) {
//                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
//
//                }
//            }
//        }];
//    }else {
//        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
//        if (resultBlock) {
//            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
//            
//        }
//    }
//}

- (void)fetchPropertyDetailWithOrderId:(NSString *)orderId result:(void (^)(TCPropertyManage *propertyManage, NSError *error))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"property_orders/propertyDetail/%@", orderId];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodGet apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.error) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(nil, response.error));
                }
            } else {
                TCPropertyManage *propertyManage = [[TCPropertyManage alloc] initWithObjectDictionary:response.data];
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(propertyManage, nil));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(nil, sessionError));
        }
    }
}

- (void)updatePropertyInfoWithOrderId:(NSString *)orderId status:(NSString *)status doorTime:(NSString *)doorTime payValue:(NSString *)payValue result:(void (^)(BOOL, NSError *))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *payVa = payValue ? [NSString stringWithFormat:@"&payValue=%@",payValue] : @"";
        NSString *apiName = [NSString stringWithFormat:@"property_orders/%@?staff=%@&status=%@%@", orderId,self.currentUserSession.assigned,status,payVa];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        if (doorTime) {
            NSInteger door = [doorTime integerValue];
            [request setValue:[NSNumber numberWithInteger:door] forKey:@"value"];
        }
        
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

- (void)cancelPropertyOrderWithOrderID:(NSString *)orderId reason:(NSString *)reasonStr result:(void(^)(BOOL success, NSError *error))resultBlock {
    if ([self isUserSessionValid]) {
        NSString *apiName = [NSString stringWithFormat:@"property_orders/%@?type=property&cancelReason=%@", orderId,reasonStr];
        TCClientRequest *request = [TCClientRequest requestWithHTTPMethod:TCClientHTTPMethodPut apiName:apiName];
        [[TCClient client] send:request finish:^(TCClientResponse *response) {
            if (response.statusCode == 200) {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(YES, nil));
                }
            } else {
                if (resultBlock) {
                    TC_CALL_ASYNC_MQ(resultBlock(NO, response.error));
                }
            }
        }];
    } else {
        TCClientRequestError *sessionError = [TCClientRequestError errorWithCode:TCClientRequestErrorUserSessionInvalid andDescription:nil];
        if (resultBlock) {
            TC_CALL_ASYNC_MQ(resultBlock(NO, sessionError));
        }
    }
}

@end
