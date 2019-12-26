//
//  UBFunctionManager.m
//  paimonkey
//
//  Created by xxx on 2018/9/27.
//  Copyright © 2018 xxx. All rights reserved.
//

#import "UBFunctionManager.h"
#import "UBDeviceInfo.h"
#import "ATAuthSDK/ATAuthSDK.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "NYMobClickHeader.h"

// 设备信息 key
static NSString * const kPMMessageKey = @"message";
//static NSString * const kPMAppsKey = @"apps";
static NSString * const kPMSelfBundlerIDKey = @"self_bundler_id";
static NSString * const kPMIDFAKey = @"idfa";
static NSString * const kPMJailBreakKey = @"jailbreak";
static NSString * const kPMVPNKey = @"vpn";
static NSString * const kPMInstalledKey = @"installed";
static NSString * const kPMOSVersionKey = @"os_version";
static NSString * const kPMDeviceModelKey = @"dev_model";
static NSString * const kPMNetworkStatusKey = @"networkStatus";
static NSString * const kPMIMSIInfoKey = @"imsi_info";
static NSString * const kPMWidthKey = @"width";
static NSString * const kPMHeightKey = @"height";
static NSString * const kPMIDFVKey = @"idfv";
static NSString * const kPMUsedTimeKey = @"used_time";
static NSString * const kPMHelperVersionKey = @"helper_version";
static NSString * const kPMOpenTimeKey = @"boot_time";
static NSString * const kPMIsChargingKey = @"charging";

static NSString * const kPMOpenid = @"openid";
static NSString * const kPMNameKey = @"name";
static NSString * const kPMIconurlKey = @"iconurl";
static NSString * const kPMUnionGender = @"unionGender";
static NSString * const kPMUsidKey = @"unionId";
static NSString * const kPMParent_idKey = @"parent_id";
static NSString * const kPMSignKey = @"sign";

static NSString * const kPMDeviceWifiMAC = @"wifi_mac";
static NSString * const kPMDeviceWifiName = @"wifi_name";
static NSString * const kPMGPS = @"GPS";
static NSString * const kPMChannel = @"channel";


@interface UBFunctionManager()

@end

@implementation UBFunctionManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static UBFunctionManager *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (NSDictionary*)actionWithAccessCodeQuery {
    NSDictionary* response = nil;
    NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
    NSString *token = [userdafault objectForKey:@"token"];
    NSString *resultCode = [userdafault objectForKey:@"resultCode"];
    
    if (token.length == 0 && resultCode.length == 0) {
        response = @{@"token":@"",
                     @"resultCode":@"网络未到达"
                     };
    }else{
        response = @{@"token":token,
                     @"resultCode":resultCode
                     };
    }
    return response;
}
+ (NSDictionary *)getInfoWithBundleID:(NSString *)bundleID {
    NSDictionary *wifiInfo = [UBDeviceInfo getWiFiInfo];
    NSString *wifi_name = wifiInfo[@"SSID"];
    NSString *wifi_mac = wifiInfo[@"BSSID"];
    if (![wifi_mac containsString:@":"]) {
       // 非wifi联网下无法获取信息
       NSLog(@"非wifi联网下无法获取信息");
       wifi_mac = @"";
       wifi_name = @"";
    }
    NSDictionary *dict = nil;
    BOOL isJB = [UBDeviceInfo isJailbroken];
    BOOL isProxy = [UBDeviceInfo isOnProxy];
    NSString *selfBundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    BOOL installed = [UBDeviceInfo isAppInstalled:bundleID];
    NSString *osVersion = [UBDeviceInfo getOSVersion];
    NSString *devModel = [UBDeviceInfo getHardwareModel];
    NSString *networkStatus = [UBDeviceInfo getNetWorkStates];
    NSDictionary *imsi = [UBDeviceInfo getIMSI];
    CGFloat width = [UBDeviceInfo getScreenWidth];
    CGFloat height = [UBDeviceInfo getScreenHeight];
    NSString *idfv = [UBDeviceInfo getIDFV];
    NSString *idfa = [UBDeviceInfo getIDFA];
    NSInteger usedTime = [self getAppUsedTimeWithBundleID:bundleID];
    NSTimeInterval openTime = [UBDeviceInfo getDeviceRespiredTime];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *helperVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    BOOL isCharging = [UBDeviceInfo isDeviceCharging];
    
    NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
    NSString *openID = [userdafault objectForKey:@"openid"];
    NSString *name = [userdafault objectForKey:@"name"];
    NSString *iconurl = [userdafault objectForKey:@"iconurl"];
    NSString *unionGender = [userdafault objectForKey:@"unionGender"];
    NSString *unionId = [userdafault objectForKey:@"unionId"];
    NSString *gps = [userdafault objectForKey:@"GPS"]?:@"";
    NSString *parent_id = [userdafault objectForKey:@"parent_id"]?:@"";

    
    NSDictionary *result = @{
        kPMMessageKey:@"ok",
        kPMSelfBundlerIDKey:selfBundleID,
        kPMIDFAKey:idfa,
        kPMJailBreakKey:@(isJB),
        kPMVPNKey:@(isProxy),
        kPMInstalledKey:@(installed),
        kPMOSVersionKey:osVersion,
        kPMDeviceModelKey:devModel,
        kPMNetworkStatusKey:networkStatus?:@"无网络",
        kPMIMSIInfoKey:imsi,
        kPMWidthKey:@(width),
        kPMHeightKey:@(height),
        kPMIDFVKey:idfv,
        kPMUsedTimeKey:@(usedTime),
        kPMHelperVersionKey:helperVersion,
        kPMOpenTimeKey:@(openTime),
        kPMIsChargingKey:@(isCharging),
        kPMOpenid:openID,
        kPMNameKey:name,
        kPMUnionGender:unionGender,
        kPMIconurlKey:iconurl,
        kPMUsidKey:unionId,
        kPMSignKey:@"drfg2iey0vmnwqpa",
        kPMDeviceWifiName:wifi_name,
        kPMDeviceWifiMAC:wifi_mac,
        kPMGPS:gps,
        kPMParent_idKey:parent_id,
        kPMChannel:selfBundleID
    };
    
    dict = @{@"result":result};
    
    return dict;
}
+ (NSString *)jumpAppOpenAppWithBundleID:(NSString *)bundleID {
    if (bundleID == nil || bundleID.length == 0) {
        return @"bundleID为空";
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", bundleID, @"kIsInstalledKey"];
    NSString *string1 = [NSString stringWithFormat:@"%@S%@Work%@",@"L",@"Application",@"space"];
    char tempChar[1000];
    strcpy(tempChar,(char *)[string1 UTF8String]);
    Class lsawsc = objc_getClass(tempChar);
    NSString *string2 = [NSString stringWithFormat:@"%@%@",@"default",@"Workspace"];
    NSObject* workspace = [lsawsc performSelector:NSSelectorFromString(string2)];
    NSString *string3 = [NSString stringWithFormat:@"%@%@With%@:",@"open",@"Application",@"BundleID"];
    BOOL open = [workspace respondsToSelector:NSSelectorFromString(string3)];
    BOOL openResult = NO;
    if (open) {
         openResult = [workspace performSelector:NSSelectorFromString(string3) withObject:bundleID];
    }
    NYLog(@"openResult = %d", openResult);

    if (openResult) {
        // 记录打开时间
        NSDate *now = [NSDate date];
        NSString *helperKey = [NSString stringWithFormat:@"paimonkey_%@", bundleID];
        
        NSDate *openDate = [[NSUserDefaults standardUserDefaults] objectForKey:helperKey];
        if (openDate == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:now forKey:helperKey];
        }
        // 设置 installed 为 true
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:key];
        return @"以安装";
    } else {

        NSLog(@"未安装该 app");
        return @"未安装";
    }
    
   
}
+ (NSInteger)getAppUsedTimeWithBundleID:(NSString *)bundleID {
    if (bundleID == nil || bundleID.length == 0) {
        return 0;
    }
    NSInteger result = 0;
    NSString *helperKey = [NSString stringWithFormat:@"paimonkey_%@", bundleID];
    NSDate * openAppDate = [[NSUserDefaults standardUserDefaults] objectForKey:helperKey];
    
    if (openAppDate) {
        NSDate *now = [NSDate date];
        NSTimeInterval time = [now timeIntervalSinceDate:openAppDate];
        result = (NSInteger)time;
        
        NYLog(@"time = %f", time);
        NYLog(@"result = %ld", (long)result);
        
    } else {
        // 还没有打开过 app
        result = 0;
    }
    
    return result;
}

+ (void)setPhoneNumToken:(NSString *)phoneNum {
    if ([[TXCommonHandler sharedInstance] checkSyncGatewayVerifyEnable:phoneNum]) {
        // 2. 获取认证预取号accessCode，用于3步骤认证接口参数
        [[TXCommonHandler sharedInstance] getAuthTokenWithComplete:^(NSDictionary * _Nonnull resultDic) {
            NYLog(@"本机号码校验结果：%@",resultDic);
            NSString *resultCode = [resultDic valueForKey:@"resultCode"];
            NSString *token = [resultDic valueForKey:@"token"];
            if (resultCode.length > 0 && [resultCode isEqualToString:@"6666"]  && token.length > 0) {
                // 3.成功，请求业务服务端API，进行认证
                NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
                [userdafault setObject:token forKey:@"token"];
                 [userdafault setObject:resultCode forKey:@"resultCode"];
                [userdafault synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"checkPhoneSuccess" object:nil];
            }
            else {
                // 4.失败，切换到业务方其他的认证方法
                NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
                [userdafault setObject:resultCode forKey:@"resultCode"];
                [userdafault setObject:@"" forKey:@"token"];
                [userdafault synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"checkPhoneSuccess" object:nil];
            }
        }];
    }
    else {
        //切换到业务方其他的认证方法
        NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
        [userdafault setObject:@"认证失败" forKey:@"resultCode"];
        [userdafault setObject:@"" forKey:@"token"];
        [userdafault synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkPhoneSuccess" object:nil];
    }
}

@end
