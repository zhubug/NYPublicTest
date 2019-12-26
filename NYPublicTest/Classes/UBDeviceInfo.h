//
//  DeviceInfo.h
//  QuZhuan
//
//  Created by Qi Liu on 2018/7/7.
//  Copyright © 2018年 Qi Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface UBDeviceInfo : NSObject


+ (BOOL)isJailbroken;

+ (NSString *)getTimestamp;

+(NSString *)getOSVersion;

+(NSString *)getNetWorkStates;

+ (BOOL)isOnProxy;

+ (BOOL)isAppInstalled:(NSString *)bundleID;

+ (NSString *)getHardwareModel;

+ (NSDictionary *)getIMSI;

+ (CGFloat)getScreenWidth;

+ (CGFloat)getScreenHeight;

+ (NSString *)getIDFV;
+ (NSString *)getIDFA;
// 单位秒
+ (NSTimeInterval)getDeviceRespiredTime;

+ (BOOL)isDeviceCharging;

+ (NSDictionary *)getWiFiInfo;

@end
