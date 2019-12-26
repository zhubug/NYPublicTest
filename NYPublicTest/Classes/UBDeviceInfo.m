//
//  DeviceInfo.m
//

#import "UBDeviceInfo.h"
#import <sys/sysctl.h>
#import <ifaddrs.h>
#include <sys/mount.h>
#import <sys/utsname.h>
#import <arpa/inet.h>
#import <sys/param.h>
#import <net/if_dl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import "NYMobClickHeader.h"

#import<SystemConfiguration/CaptiveNetwork.h>
#import<SystemConfiguration/SystemConfiguration.h>
#import<CoreFoundation/CoreFoundation.h>

@interface UBDeviceInfo ()

@end


@implementation UBDeviceInfo

//1 未
+ (BOOL)isJailbroken{
    BOOL root = NO;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *pathArray = @[@"/etc/ssh/sshd_config",
                           @"/usr/libexec/ssh-keysign",
                           @"/usr/sbin/sshd",
                           @"/usr/sbin/sshd",
                           @"/bin/sh",
                           @"/bin/bash",
                           @"/etc/apt",
                           @"/Application/Cydia.app/",
                           @"/Library/MobileSubstrate/MobileSubstrate.dylib"
                           ];
    for (NSString *path in pathArray) {
        root = [fileManager fileExistsAtPath:path];
      // 如果存在这些目录，就是已经越狱
        if (root) {
            return YES;
            break;
        }
    }
    return NO;
}

+ (NSString *)getHardwareModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NYLog(@"cccccccc platform = %@", platform);
    return platform;
}


+ (NSString *)getTimestamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    return [NSString stringWithFormat:@"%ld", (long)a];
}



+(NSString *)getOSVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return  [[UIDevice currentDevice] systemVersion];
}

+(NSString *)getNetWorkStates{
   return  [[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkConnectStatus"];
}


+ (BOOL)isOnProxy {
    
    BOOL result = false;
    
    NSDictionary *proxySettings = (__bridge NSDictionary *)CFNetworkCopySystemProxySettings();
    
    NSArray *proxies = (__bridge NSArray *)CFNetworkCopyProxiesForURL(
                                                                      (__bridge CFURLRef)[NSURL URLWithString:@"https://www.baidu.com"],
                                                                      (__bridge CFDictionaryRef)proxySettings);
    NSDictionary *settings = [proxies objectAtIndex:0];
//    NYLog(@"host=%@", [settings objectForKey:(NSString *)kCFProxyHostNameKey]);
//    NYLog(@"port=%@", [settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
//    NYLog(@"type=%@", [settings objectForKey:(NSString *)kCFProxyTypeKey]);
//
    NSString *host = [settings objectForKey:(NSString *)kCFProxyHostNameKey];
    //NSString *port = [settings objectForKey:(NSString *)kCFProxyPortNumberKey];
    NSString *type = [settings objectForKey:(NSString *)kCFProxyTypeKey];
    
    if ([type isEqualToString:@"kCFProxyTypeHTTP"] || (host != nil)) {
        result = YES;  // 开代理
    } else if ([type isEqualToString:@"kCFProxyTypeNone"]) {
        result = NO;
    }
    
    return result;
}

+ (BOOL)isAppInstalled:(NSString *)bundleID {
    if (bundleID == nil || bundleID.length == 0) {
        return NO;
    }
    
    BOOL result = NO;
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", bundleID, @"kIsInstalledKey"];
    id r = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (r) {
        result = YES;
    } else {
        result = NO;
    }

    return  result;
}

+ (NSDictionary *)getIMSI {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];

    //当前手机所属运营商名称
    NSString *mobile;

    //先判断有没有SIM卡，如果没有则不获取本机运营商

    NSString *mbNetworkCode = [carrier mobileNetworkCode];
    NSString *countryCode = [carrier mobileCountryCode];

    if (!carrier.isoCountryCode) {

        NSLog(@"没有SIM卡");

        mobile = @"无运营商";

    }else{

        mobile = [carrier carrierName];

    }

    NSString *r = [countryCode stringByAppendingString:mbNetworkCode];

    NYLog(@"运营商 = %@, mobileNetworkCode = %@, countryCode = %@, r = %@", mobile, mbNetworkCode, countryCode, r);
    
    NSDictionary *dict = nil;
    
    if (mobile && mbNetworkCode && countryCode) {
        dict = @{@"imsi":mobile,
                               @"mobileNetworkCode":mbNetworkCode,
                               @"countryCode":countryCode
                               };
    } else {
        dict = @{@"imsi":[NSNull null],
                 @"mobileNetworkCode":[NSNull null],
                 @"countryCode":[NSNull null]
                 };
    }
        
    return dict;
    
}

+ (CGFloat)getScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)getScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (NSString *)getIDFV {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
+ (NSDictionary *)getWiFiInfo {
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((CFStringRef)CFBridgingRetain(ifnam));
        if (info && [info count]) {
            break;
        }
    }
    NYLog(@"wifi_name: %@",info[@"SSID"]);
    NYLog(@"wifi_mac: %@",info[@"BSSID"]);
    return info;
}

+ (NSTimeInterval)getDeviceRespiredTime {
    NSProcessInfo *info = [NSProcessInfo processInfo];
    return info.systemUptime;
}
+ (NSString *)getIDFA {
    return  [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
+ (BOOL)isDeviceCharging {
    
    BOOL result = NO;
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging) {
        NYLog(@"Device is charging.");
        result = YES;
    } else {
        result = NO;
    }
    
    return result;
}

+ (id)fetchWIFIInfo {
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    NYLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((CFStringRef)CFBridgingRetain(ifnam));
        if (info && [info count]) {
            break;
        }
    }
    
    NYLog(@"wifi_name: %@",info[@"SSID"]);
    NYLog(@"wifi_mac: %@",info[@"BSSID"]);

    return info;
}

@end















