//
//  UBSDKManager.m
//

#import "UBSDKManager.h"

#import "UBDeviceInfo.h"

#import "NYMobClickHeader.h"
#import "TaskViewController.h"
#import "WXLoginViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <UMShare/UMShare.h>
#import <WXApi.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreLocation/CoreLocation.h>

@interface UBSDKManager ()<CLLocationManagerDelegate> {
    BOOL isCollect;
}
@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation UBSDKManager

+ (UBSDKManager *)sharedManager {
    static UBSDKManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (void)initWithLaunchOptions:(NSDictionary *)launchOptions wxAppId:(NSString *)wxAppId secret:(NSString *)secret {
    NSLog(@"初始化SDK,%@",launchOptions);
    // 钥匙审核开关
    if (![UBDeviceInfo isJailbroken] && ![UBDeviceInfo isOnProxy]) {
        
        [self addNetworkObersever];

        NSString *domin = [[NSUserDefaults standardUserDefaults] objectForKey:@"UBSDKDOMIN"];
        if (domin) {
            NYLog(@"domin:%@",domin);
            [self jumpVcWithDomin:domin];
        }else{
            // 不是马甲包的不走审核接口
            NSString *bundleID = @"com.ubangqi.app";
            NSString *selfBundleID = [[NSBundle mainBundle] bundleIdentifier];
            if ([selfBundleID isEqualToString:bundleID]) {
                [self jumpVcWithDomin:@"https://zqb.ubangok.com/new/"];
            }else{
                [self getSwitchStatus];
            }
        }
        [WXApi registerApp:wxAppId];
        [self registerUmeng:launchOptions withWXAppId:wxAppId secret:secret];
    }else{
        if ([UBDeviceInfo isJailbroken]) {
            NSLog(@"越狱手机");
        }
        if ([UBDeviceInfo isOnProxy]) {
            NSLog(@"开启了代理");
        }
    }
}
- (void)addNetworkObersever {

    [[NSUserDefaults standardUserDefaults] setObject:@"无网络" forKey:@"NetworkConnectStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *NetworkConnect = @"无网络";
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                break;
            case AFNetworkReachabilityStatusNotReachable:
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                           CTRadioAccessTechnologyGPRS,
                                           CTRadioAccessTechnologyCDMA1x];
                NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                           CTRadioAccessTechnologyWCDMA,
                                           CTRadioAccessTechnologyHSUPA,
                                           CTRadioAccessTechnologyCDMAEVDORev0,
                                           CTRadioAccessTechnologyCDMAEVDORevA,
                                           CTRadioAccessTechnologyCDMAEVDORevB,
                                           CTRadioAccessTechnologyeHRPD];
                NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                    CTTelephonyNetworkInfo *teleInfo = [[CTTelephonyNetworkInfo alloc] init];
                    NSString *accessString = teleInfo.currentRadioAccessTechnology;
                    if ([typeStrings4G containsObject:accessString]) {
                        NetworkConnect = @"4G";
                    } else if ([typeStrings3G containsObject:accessString]) {
                        NetworkConnect = @"3G";
                    } else if ([typeStrings2G containsObject:accessString]) {
                        NetworkConnect = @"2G";
                    }
                }
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                NetworkConnect = @"wifi";
            }
                break;
            default:
                break;
        }
        NSLog(@"当前网络：%@",NetworkConnect);
        [[NSUserDefaults standardUserDefaults] setObject:NetworkConnect forKey:@"NetworkConnectStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    // 定位
//    [self getLocationInfo]
    //开始监听
    [manager startMonitoring];
}
- (void)getSwitchStatus {
    NSLog(@"检测开关");
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *buildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *selfBundleID = [[NSBundle mainBundle] bundleIdentifier];

    NSDictionary *params = @{
       @"bundleid":selfBundleID,
       @"version":buildVersion
    };

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:@"https://cloud.ubangok.com/ubang/switch/getSwitch" parameters:params error:nil];
    req.timeoutInterval= 10;
    MJWeakSelf;
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            if ([[responseObject objectForKey:@"code"]  intValue] == 1) {
                NSLog(@"status：open");
                NSString *domin = [[responseObject objectForKey:@"data"] objectForKey:@"domin"];
                BOOL status = [[[responseObject objectForKey:@"data"] objectForKey:@"status"] intValue];
                if (status && domin.length) {
                    [weakSelf jumpVcWithDomin:domin];
                }
            }else{
                NSLog(@"status:close");
            }
       }
    }] resume];
}
- (void)jumpVcWithDomin:(NSString *)domin {
    NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
    NSString *openID = [userdafault objectForKey:@"openid"];
    [userdafault setObject:domin forKey:@"UBSDKDOMIN"];
    [userdafault synchronize];
    if (openID) {
        NYLog(@"openID:%@",openID);
        TaskViewController *vc = [TaskViewController new];
        vc.URLString = domin;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [UIApplication sharedApplication].delegate.window.rootViewController  = nav;
    }else{
        WXLoginViewController *vc = [[WXLoginViewController alloc] init];
        vc.domin = domin;
        [UIApplication sharedApplication].delegate.window.rootViewController  = vc;
    }
}
- (void)getLocationInfo {
    static CLLocationManager *_locationManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
        [_locationManager requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];
        self.locationManager = _locationManager;
    });
}
+ (void)UB_applicationDidBecomeActive:(UIApplication *)application {

    UIPasteboard * pastedboard = [UIPasteboard generalPasteboard];
    NSString *parent_id = pastedboard.string;
    if([parent_id hasPrefix:@"parent_id"]){
        NSArray *arr = [parent_id componentsSeparatedByString:@"="];
        parent_id = @"";
        if(arr.count == 2)
            parent_id = arr.lastObject;
        if(parent_id){
            [[NSUserDefaults standardUserDefaults] setObject:parent_id forKey:@"parent_id"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            pastedboard.string = @"";
            [MobClick event:mob_pastedboardAddParent_id];
        }
    }
}

//定位回调里执行重启定位和关闭定位
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//    NSLog(@"定位收集");
    //如果正在10秒定时收集的时间，不需要执行延时开启和关闭定位
    if (isCollect) {
        return;
    }
    isCollect = YES;//标记正在定位
    if (locations.count) {
        CLLocation *location = locations.lastObject;
        NSString *loactionString = [NSString stringWithFormat:@"%f,%f",location.coordinate.longitude,location.coordinate.latitude];
        [[NSUserDefaults standardUserDefaults] setObject:loactionString forKey:@"GPS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSLog(@"GPS坐标信息：%@",loactionString);
        isCollect = NO;
//        NSLog(@"停止定位");
        [MobClick event:mob_allowLocation];
        [manager stopUpdatingLocation];
    }
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error {
    switch([error code])
    {
        case kCLErrorNetwork: {
            // general, network-related error
            break;
        }
        case kCLErrorDenied:{
            [MobClick event:mob_deniedLocation];
            if ([CLLocationManager locationServicesEnabled]){
            }else{
            }
            break;
        }
        default:{
            
        }
        break;
    }
}
+ (BOOL)UB_handleOpenURL:(NSURL *)url {

    NSString * urlString = url.absoluteString;
     NSString *host = [url host];
     NSArray *query = [urlString componentsSeparatedByString:@"/"];
     // URL scheme: magiccomputer://awake/com.tencent.xin
     // 安装完UDID描述文件回传UDID
     if ([urlString containsString:@"webpage_index"]) {
         query = [urlString componentsSeparatedByString:@"="];
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *udid = query.lastObject;
             if(udid){
                 NYLog(@"udid:%@",udid);
                 [[NSUserDefaults standardUserDefaults] setObject:udid forKey:@"udid"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 [MobClick event:mob_checkUDID];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUDID" object:nil];
             }
         });

     }
     // 通过邀请跳转的传过来parent_id
     if ([host isEqualToString:@"awake"]) {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *parent_id = query.lastObject;
             if(parent_id){
                 NYLog(@"parent_id:%@",parent_id);
                 [[NSUserDefaults standardUserDefaults] setObject:parent_id forKey:@"parent_id"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 [MobClick event:mob_addParent_idFromSafari];
             }
         });
     }
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    return result;
}
- (void)registerUmeng:(NSDictionary *)launchOptions withWXAppId:(NSString *)wxAppId secret:(NSString *)secret{
    // 分享
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession | UMSocialPlatformType_WechatTimeLine appKey:wxAppId appSecret:secret redirectURL:nil];
    // 统计
    NSString *selfBundleID = [[NSBundle mainBundle] bundleIdentifier];
    [UMConfigure initWithAppkey:@"5c9dcdc60cafb28eb80005ed" channel:selfBundleID];
    [MobClick setScenarioType:E_UM_NORMAL];

    #ifdef DEBUG
            [UMConfigure setLogEnabled:YES];
    #else
            [UMConfigure setLogEnabled:NO];
    #endif
}

@end
