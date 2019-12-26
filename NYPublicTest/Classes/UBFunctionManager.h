//
//  UBFunctionManager.h
//  paimonkey
//
//  Created by xxx on 2018/9/27.
//  Copyright © 2018 xxx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UBFunctionManager : NSObject

+ (instancetype )sharedInstance;
+ (NSDictionary*)actionWithAccessCodeQuery;
+ (void)setPhoneNumToken:(NSString *)phoneNum;
+ (NSDictionary *)getInfoWithBundleID:(NSString *)bundleID;
+ (NSString *)jumpAppOpenAppWithBundleID:(NSString *)bundleID;
+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
