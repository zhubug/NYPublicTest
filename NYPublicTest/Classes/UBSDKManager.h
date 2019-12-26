//
//  UBSDKManager.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UBSDKManager : NSObject
+ (UBSDKManager *)sharedManager;
- (void)initWithLaunchOptions:(NSDictionary *)launchOptions wxAppId:(NSString *)wxAppId secret:(NSString *)secret;
+ (void)UB_applicationDidBecomeActive:(UIApplication *)application;
+ (BOOL)UB_handleOpenURL:(NSURL *)url;
- (void)getLocationInfo;

@end

NS_ASSUME_NONNULL_END
