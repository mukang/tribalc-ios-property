//
//  TCLinphoneUtils.h
//  individual
//
//  Created by 王帅锋 on 16/12/15.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinphoneManager.h"
@class Contact;

#define IPAD (LinphoneManager.runningOnIpad)
#define ANIMATED ([LinphoneManager.instance lpConfigBoolForKey:@"animations_preference"])
#define LC ([LinphoneManager getLc])

@interface LinphoneUtils : NSObject

+ (BOOL)findAndResignFirstResponder:(UIView*)view;
+ (void)adjustFontSize:(UIView*)view mult:(float)mult;
+ (void)buttonFixStates:(UIButton*)button;
+ (void)buttonMultiViewAddAttributes:(NSMutableDictionary*)attributes button:(UIButton*)button;
+ (void)buttonMultiViewApplyAttributes:(NSDictionary*)attributes button:(UIButton*)button;
+ (NSString *)deviceModelIdentifier;

+ (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)addr;

typedef enum {
    LinphoneDateHistoryList,
    LinphoneDateHistoryDetails,
    LinphoneDateChatList,
    LinphoneDateChatBubble,
} LinphoneDateFormat;

+ (NSString *)timeToString:(time_t)time withFormat:(LinphoneDateFormat)format;

+ (BOOL)hasSelfAvatar;
+ (UIImage *)selfAvatar;

+ (NSString *)durationToString:(int)duration;

@end

@interface NSNumber (HumanReadableSize)

- (NSString*)toHumanReadableSize;

@end

@interface NSString (linphoneExt)

- (NSString *)md5;
- (BOOL)containsSubstring:(NSString *)str;

@end

@interface UIImage (squareCrop)

- (UIImage *)squareCrop;
- (UIImage *)scaleToSize:(CGSize)size squared:(BOOL)squared;

@end

@interface ContactDisplay : NSObject
+ (void)setDisplayNameLabel:(UILabel *)label forContact:(Contact *)contact;
+ (void)setDisplayNameLabel:(UILabel *)label forAddress:(const LinphoneAddress *)addr;
@end

#import <UIKit/UIColor.h>
#import <UIKit/UIKit.h>

#define LINPHONE_MAIN_COLOR [UIColor colorWithRed:207.0f / 255.0f green:76.0f / 255.0f blue:41.0f / 255.0f alpha:1.0f]
#define LINPHONE_SETTINGS_BG_IOS7 [UIColor colorWithRed:164 / 255. green:175 / 255. blue:183 / 255. alpha:1.0]

@interface UIColor (LightAndDark)

- (UIColor *)adjustHue:(float)hm saturation:(float)sm brightness:(float)bm alpha:(float)am;

- (UIColor *)lumColor:(float)mult;

- (UIColor *)lighterColor;

- (UIColor *)darkerColor;

@end

@interface UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image;

@end

/* Use that macro when you want to invoke a custom initialisation method on your class,
 whatever is using it (xib, source code, etc., tableview cell) */
#define INIT_WITH_COMMON_C                                                                                             \
-(instancetype)init {                                                                                              \
return [[super init] commonInit];                                                                              \
}                                                                                                                  \
-(instancetype)initWithCoder : (NSCoder *)aDecoder {                                                               \
return [[super initWithCoder:aDecoder] commonInit];                                                            \
}                                                                                                                  \
-(instancetype)commonInit

#define INIT_WITH_COMMON_CF                                                                                            \
-(instancetype)initWithFrame : (CGRect)frame {                                                                     \
return [[super initWithFrame:frame] commonInit];                                                               \
}                                                                                                                  \
INIT_WITH_COMMON_C

