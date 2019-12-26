//
//  NYMobClickHeader.h
//  RainbowTeacher
//
//  Created by zhunanyang on 2019/12/5.
//  Copyright © 2019 Ubang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define mob_wxLogin                      @"wxLogin"
#define mob_userTokenLogin               @"userTokenLogin"
#define mob_deniedLocation               @"deniedLocation"
#define mob_getUDID                      @"getUDID"
#define mob_inviteBtnClick               @"inviteBtnClick"
#define mob_withdrawBtnClick             @"withdrawBtnClick"
#define mob_shareToWx                    @"shareToWx"
#define mob_homepageRefreshBtnClick      @"homepageRefreshBtnClick"
#define mob_checkUDID                    @"checkUDID"
#define mob_getRewardsClick              @"getRewardsClick"
#define mob_shareToFriendly              @"shareToFriendly"
#define mob_shareClick                   @"shareClick"
#define mob_homepageQuikTaskClick        @"homepageQuikTaskClick"
#define mob_taskClick                    @"taskClick"
#define mob_allowLocation                @"allowLocation"
#define mob_pastedboardAddParent_id      @"pastedboardAddParent_id"
#define mob_addParent_idFromSafari       @"addParent_idFromSafari"
#define MJWeakSelf __weak typeof(self) weakSelf = self;

// 控制台输出
#ifdef DEBUG
#define NYLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define NYLog(...)
#endif

@interface NYMobClickHeader : NSObject

@end

NS_ASSUME_NONNULL_END
