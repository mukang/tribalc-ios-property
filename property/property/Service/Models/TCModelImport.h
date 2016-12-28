//
//  TCModelImport.h
//  individual
//
//  Created by 穆康 on 2016/11/9.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//


/********** 用户相关 **********/

#import "TCUserSession.h"
#import "TCUserInfo.h"
#import "TCUserSensitiveInfo.h"
#import "TCUserSipInfo.h"
#import "TCUserPhoneInfo.h"
#import "TCUserAddress.h"
#import "TCUserShippingAddress.h"
#import "TCWalletAccount.h"
#import "TCWalletBill.h"
#import "TCWalletBillWrapper.h"
#import "TCBankCard.h"
#import "TCUserCompanyInfo.h"
#import "TCUserIDAuthInfo.h"
#import "TCUserPayment.h"

/********** 商业相关 **********/

#import "TCGoods.h"
#import "TCGoodsWrapper.h"
#import "TCGoodDetail.h"
#import "TCGoodStandards.h"
#import "TCStoreInfo.h"

/********** 服务相关 **********/
#import "TCServiceWrapper.h"
#import "TCServices.h"
#import "TCServiceDetail.h"
#import "TCMarkStore.h"
#import "TCListStore.h"
#import "TCDetailStore.h"

/********** 订单相关 **********/
//#import "TCOrderWrapper.h"
//#import "TCOrderItem.h"
//#import "TCOrder.h"

/********** 预订相关 **********/
#import "TCReservationWrapper.h"
#import "TCReservation.h"
#import "TCReservationDetail.h"

/********** 购物车相关 **********/
#import "TCShoppingCartWrapper.h"
#import "TCListShoppingCart.h"
#import "TCCartItem.h"

/********** OSS上传相关 **********/

#import "TCUploadInfo.h"

/********** 社区相关 **********/

//#import "TCCommunity.h"
//#import "TCCommunityDetailInfo.h"
//#import "TCCommunityListInCity.h"
//#import "TCCommunityReservationInfo.h"

/********** 公司相关 **********/

#import "TCCompanyInfo.h"

/********** 物业报修 **********/
#import "TCPropertyManageWrapper.h"
#import "TCPropertyManage.h"
#import "TCPropertyRepairsInfo.h"


@interface TCModelImport : NSObject

@end
