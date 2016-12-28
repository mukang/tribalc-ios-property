//
//  TCShoppingCartSelectButton.h
//  individual
//
//  Created by WYH on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCShoppingCartSelectButton : UIButton

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, assign) BOOL hiddenSelectButton;

@end
