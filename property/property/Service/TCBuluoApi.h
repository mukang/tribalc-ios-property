//
//  TCBuluoApi.h
//  individual
//
//  Created by 穆康 on 2016/11/3.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TCModelImport.h"

extern NSString *const TCBuluoApiNotificationUserDidLogin;
extern NSString *const TCBuluoApiNotificationUserDidLogout;
extern NSString *const TCBuluoApiNotificationUserInfoDidUpdate;

typedef NS_ENUM(NSInteger, TCPayChannel) {
    TCPayChannelBalance = 0,  // 余额
    TCPayChannelAlipay,       // 支付宝
    TCPayChannelWechat,       // 微信
    TCPayChannelBankCard      // 银行卡
};

@interface TCBuluoApi : NSObject

/**
 获取api实例
 
 @return 返回TCBuluoApi实例
 */
+ (instancetype)api;

#pragma mark - 设备相关

@property (nonatomic, assign, readonly, getter=isPrepared) BOOL prepared;

/**
 准备工作

 @param completion 准备完成回调
 */
- (void)prepareForWorking:(void(^)(NSError * error))completion;

#pragma mark - 用户会话相关

/**
 检查是否需要重新登录

 @return 返回BOOL类型的值，YES表示需要，NO表示不需要
 */
- (BOOL)needLogin;

/**
 获取当前已登录用户的会话

 @return 返回currentUserSession实例，返回nil表示当前没有保留的已登录会话或会话已过期
 */
- (TCUserSession *)currentUserSession;

#pragma mark - 普通用户资源

/**
 用户登录，登录后会保留登录状态

 @param phoneInfo 用户登录信息，TCUserPhoneInfo对象
 @param resultBlock 结果回调，userSession为nil时表示登录失败，失败原因见error的code和userInfo
 */
- (void)login:(TCUserPhoneInfo *)phoneInfo result:(void (^)(TCUserSession *userSession, NSError *error))resultBlock;

/**
 用户注销，会检查登录状态，已登录的会撤销登录状态，未登录的情况下直接返回成功

 @param resultBlock 结果回调，success为NO时表示登出失败，失败原因见error的code和userInfo
 */
- (void)logout:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 获取用户基本信息

 @param userID 用户ID
 @param resultBlock 结果回调，userInfo为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchUserInfoWithUserID:(NSString *)userID result:(void (^)(TCUserInfo *userInfo, NSError *error))resultBlock;

/**
 修改用户昵称
 
 @param nickname 要改为的昵称
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserNickname:(NSString *)nickname result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户头像

 @param avatar 用户头像地址
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserAvatar:(NSString *)avatar result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户背景图

 @param cover 用户背景图地址
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserCover:(NSString *)cover result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户性别

 @param gender 性别枚举值（只能传入TCUserGenderMale和TCUserGenderFemale）
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserGender:(TCUserGender)gender result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户出生日期

 @param birthdate 出生日期
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserBirthdate:(NSDate *)birthdate result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户情感状况

 @param emotionState 情感状况枚举值（不能传入TCUserEmotionStateUnknown）
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserEmotionState:(TCUserEmotionState)emotionState result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户常用地址

 @param userAddress 常用地址，TCUserAddress对象
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserAddress:(TCUserAddress *)userAddress result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 修改用户手机（敏感信息）

 @param phoneInfo TCUserPhoneInfo对象
 @param resultBlock 结果回调，success为NO时表示修改失败，失败原因见error的code和userInfo
 */
- (void)changeUserPhone:(TCUserPhoneInfo *)phoneInfo result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 查询公司绑定请求状态

 @param resultBlock 结果回调，userCompanyInfo为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchCompanyBlindStatus:(void (^)(TCUserCompanyInfo *userCompanyInfo, NSError *error))resultBlock;

/**
 用户绑定公司

 @param userCompanyInfo TCUserCompanyInfo对象
 @param resultBlock 结果回调，success为NO时表示绑定失败，失败原因见error的code和userInfo
 */
- (void)bindCompanyWithUserCompanyInfo:(TCUserCompanyInfo *)userCompanyInfo result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 认证用户身份

 @param userIDAuthInfo TCUserIDAuthInfo对象
 @param resultBlock 结果回调，认证状态请查看sensitiveInfo中的authorizedStatus字段，sensitiveInfo为nil时表示请求失败，原因见error的code和userInfo
 */
- (void)authorizeUserIdentity:(TCUserIDAuthInfo *)userIDAuthInfo result:(void (^)(TCUserInfo *sensitiveInfo, NSError *error))resultBlock;

#pragma mark - 验证码资源

/**
 获取手机验证码
 
 @param phone 手机号码
 @param resultBlock 结果回调，success为NO时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchVerificationCodeWithPhone:(NSString *)phone result:(void (^)(BOOL success, NSError *error))resultBlock;

/**
 认证图片信息

 @param imageData 图片数据
 @param resultBlock 回调结果，uploadInfo是上传图片数据所需的信息，uploadInfo为nil时表示认证失败，失败原因见error的code和userInfo
 */
- (void)authorizeImageData:(NSData *)imageData result:(void (^)(TCUploadInfo *uploadInfo, NSError *error))resultBlock;

#pragma mark - 商品类资源

/**
 获取商品列表

 @param limitSize 获取的数量
 @param sortSkip 默认查询止步的时间和跳过条数，以逗号分隔，如“1478513563773,3”表示查询早于时间1478513563773并跳过后3条记录，首次获取数据和下拉刷新数据时该参数传nil，上拉获取更多数据时该参数传上一次从服务器获取到的TCGoodsWrapper对象中属性nextSkip的值
 @param resultBlock 结果回调，goodsWrapper为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchGoodsWrapper:(NSUInteger)limitSize sortSkip:(NSString *)sortSkip result:(void (^)(TCGoodsWrapper *goodsWrapper, NSError *error))resultBlock;

/**
 获取商品详情
 
 @param goodsID 商品的ID
 @param resultBlock 结果回调，TCGoodDetail为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchGoodDetail:(NSString *)goodsID result:(void (^)(TCGoodDetail *goodDetail, NSError *error))resultBlock;

/**
 获取商品规格
 
 @param goodStandardId 商品规格的ID
 @param resultBlock 结果回调，TCGoodStandards为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchGoodStandards:(NSString *)goodStandardId result:(void (^)(TCGoodStandards *goodStandard, NSError *error))resultBlock;


#pragma mark - 服务类资源

/**
 获取服务列表
 
 @param category 类型
 @param limitSize 获取的数量
 @param sortSkip 默认查询止步的时间和跳过条数，以逗号分隔，如“1478513563773,3”表示查询早于时间1478513563773并跳过后3条记录，首次获取数据和下拉刷新数据时该参数传nil，上拉获取更多数据时该参数传上一次从服务器获取到的TCGoodsWrapper对象中属性nextSkip的值
 @param sort 排序类型
 @param resultBlock 结果回调，goodsWrapper为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchServiceWrapper:(NSString *)category limiSize:(NSUInteger)limitSize sortSkip:(NSString *)sortSkip sort:(NSString *)sort result:(void (^)(TCServiceWrapper *serviceWrapper, NSError *error))resultBlock;

/**
 获取商品详情
 
 @param serviceID 服务的ID
 @param resultBlock 结果回调，TCGoodDetail为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchServiceDetail:(NSString *)serviceID result:(void (^)(TCServiceDetail *serviceDetail, NSError *error))resultBlock;

#pragma mark - 上传图片资源

/**
 上传图片资源

 @param image 要上传的图片
 @param progress 上传进度
 @param resultBlock 结果回调，success为NO时表示上传失败，失败原因见error的code和userInfo
 */
- (void)uploadImage:(UIImage *)image progress:(void (^)(NSProgress *progress))progress result:(void (^)(BOOL success, TCUploadInfo *uploadInfo, NSError *error))resultBlock;

#pragma mark - 社区资源

/**
 获取按城市分好组的社区列表

 @param resultBlock 结果回调，communities为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchCommunityListGroupByCity:(void (^)(NSArray *communities, NSError *error))resultBlock;

#pragma mark - 公司资源

/**
 获取社区内的公司列表

 @param communityID 所在社区的ID
 @param resultBlock 结果回调，companyList为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchCompanyList:(NSString *)communityID result:(void (^)(NSArray *companyList, NSError *error))resultBlock;

#pragma mark - 物业报修

/**
 获取物业报修列表
 
 @param status 报修订单状态，传nil表示获取全部类型的订单
 @param count  获取数量
 @param sortSkip 默认查询止步的时间和跳过条数，以逗号分隔，如“1478513563773,3”表示查询早于时间1478513563773并跳过后3条记录，首次获取数据和下拉刷新数据时该参数传nil，上拉获取更多数据时该参数传上一次从服务器获取到的TCPropertyManageWrapper对象中属性nextSkip的值
 @param resultBlock 结果回调，propertyManageWrapper为nil时表示获取失败，失败原因见error的code和userInfo
 */
- (void)fetchPropertyWrapper:(NSString *)status count:(NSUInteger)count sortSkip:(NSString *)sortSkip result:(void (^)(TCPropertyManageWrapper *propertyManageWrapper, NSError *error))resultBlock;
//
///**
// 手机开门
//*/
//- (void)openDoorWithResult:(void (^)(BOOL, NSError *))resultBlock;

/**
 获取物业报修订单详情

 @param orderId 订单号
 @param resultBlock propertyManage
 */
- (void)fetchPropertyDetailWithOrderId:(NSString *)orderId result:(void (^)(TCPropertyManage *propertyManage, NSError *error))resultBlock;

/**
 修改物业报修订单信息

 @param orderId 订单号
 @param status 要修改的订单状态
 @param doorTime 上门时间
 @param resultBlock 回调
 */
- (void)updatePropertyInfoWithOrderId:(NSString *)orderId status:(NSString *)status doorTime:(NSString *)doorTime payValue:(NSString *)payValue result:(void (^)(BOOL success, NSError *error))resultBlock;


/**
 取消物业报修订单
 
 @param orderId 订单号
 @param resultBlock 结果回调success为NO时表示提交失败
 */
- (void)cancelPropertyOrderWithOrderID:(NSString *)orderId reason:(NSString *)reasonStr result:(void(^)(BOOL success, NSError *error))resultBlock;
@end
