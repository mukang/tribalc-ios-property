//
//  TCBiographyAvatarViewCell.m
//  individual
//
//  Created by 穆康 on 2016/10/28.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCBiographyAvatarViewCell.h"
#import "TCImageURLSynthesizer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TCBiographyAvatarViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation TCBiographyAvatarViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.avatarImageView.layer.cornerRadius = 30;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)setAvatar:(NSString *)avatar {
    _avatar = avatar;
    
    if (!avatar) {
        [self.avatarImageView setImage:[UIImage imageNamed:@"profile_default_avatar_icon"]];
    } else {
        UIImage *currentAvatarImage = self.avatarImageView.image;
        NSURL *URL = [TCImageURLSynthesizer synthesizeImageURLWithPath:avatar];
        [self.avatarImageView sd_setImageWithURL:URL placeholderImage:currentAvatarImage options:SDWebImageRetryFailed];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
