//
//  ZNYBundleManager.h
//  UbangSDK
//
//  Created by zhunanyang on 2019/12/6.
//  Copyright © 2019 ZNY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZNYBundleManager : NSObject
+ (NSString *)getFilePathFromBundle: (NSString *) filePathInBundle;
@end

NS_ASSUME_NONNULL_END
