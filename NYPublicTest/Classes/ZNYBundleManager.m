//
//  ZNYBundleManager.m
//  UbangSDK
//
//  Created by zhunanyang on 2019/12/6.
//  Copyright © 2019 ZNY. All rights reserved.
//

#import "ZNYBundleManager.h"

@implementation ZNYBundleManager

+ (NSBundle *)getBundle {
    return [NSBundle bundleWithPath: [[NSBundle mainBundle] pathForResource:@"ubangResource" ofType: @"bundle"]];
}

+ (NSString *)getFilePathFromBundle: (NSString *) filePathInBundle{
    NSBundle *myBundle = [ZNYBundleManager getBundle];
    if (myBundle && filePathInBundle) {
        return [[myBundle resourcePath] stringByAppendingPathComponent: filePathInBundle];
    }
    return nil;
}


@end
