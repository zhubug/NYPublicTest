//
//  TXCommonHandler.h
//  ATAuthSDK
//
//  Created by yangli on 15/03/2018.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TXCustomModel.h"

@interface TXCommonHandler : NSObject

/*
 * 函数名：sharedInstance
 * 参数：无
 * 返回：单例
 */
+ (instancetype _Nonnull )sharedInstance;

/*
 * 函数名：getVersion
 * 参数：无
 * 返回：字符串，sdk版本号
 */
- (NSString *_Nonnull)getVersion;

/**
 * @brief   同步验证网关认证所需的蜂窝数据网络是否开启（注意：会阻塞当前线程）,同原checkGatewayVerifyEnable
 * @param   phoneNumber 手机号码，非必传，号码认证且双sim卡时必须传入待验证的手机号码！！，一键登录时设置为nil即可
 * @return  BOOL值，YES表示网关认证所需的蜂窝数据网络已开启，且SDK初始化完成，NO表示未开启，只有YES才能保障后续服务
 */
- (BOOL)checkSyncGatewayVerifyEnable:(NSString *_Nullable)phoneNumber;

/**
 * @brief  异步验证网关认证所需的蜂窝数据网络是否开启（注意：不会阻塞当前线程，但是结果会异步回调）
 * @param  phoneNumber   手机号码，非必传，号码认证且双sim卡时必须传入待验证的手机号码！！，一键登录时设置为nil即可
 * @param  complete 结果回调（注意：回调线程非调用线程）
 */
- (void)checkAsyncGatewayVerifyEnable:(NSString *_Nullable)phoneNumber complete:(void(^_Nullable)(BOOL enable))complete;


/*
 * 函数名：getAuthTokenWithComplete，默认超时时间3.0s
 * 参数：无
 * 返回：字典形式
 *      resultCode：6666-成功，5555-超时，4444-失败，3344-参数异常，2222-无网络，1111-无SIM卡
 *      token：号码认证token
 *      msg：文案或错误提示
 */

- (void)getAuthTokenWithComplete:(void (^_Nullable)(NSDictionary * _Nonnull resultDic))complete;

/*
 * 函数名：getAuthTokenWithTimeout
 * 参数：timeout：接口超时时间，单位s，默认3.0s，值为0.0时采用默认超时时间
 * 返回：字典形式
 *      resultCode：6666-成功，5555-超时，4444-失败，3344-参数异常，2222-无网络，1111-无SIM卡
 *      token：号码认证token
 *      msg：文案或错误提示
 */

- (void)getAuthTokenWithTimeout:(NSTimeInterval )timeout complete:(void (^_Nullable)(NSDictionary * _Nonnull resultDic))complete;

/*
 * 函数名：getLoginNumberWithTimeout，一键登录预取号
 * 参数：
 timeout：接口超时时间，单位s，默认3.0s，值为0.0时采用默认超时时间
 * 返回：字典形式
 *      resultCode：6666-成功，5555-超时，4444-失败，3344-参数异常，2222-无网络，1111-无SIM卡
 *      msg：文案或错误提示
 */

- (void)getLoginNumberWithTimeout:(NSTimeInterval )timeout complete:(void (^_Nullable)(NSDictionary * _Nonnull resultDic))complete;

/*
 * 函数名：getLoginTokenWithController，一键登录token
 * 参数：
 vc：当前vc容器，用于一键登录授权页面切换
 model：自定义授权页面选项，可为nil，采用默认的授权页面，具体请参考TXCustomModel.h文件
 timeout：接口超时时间，单位s，默认3.0s，值为0.0时采用默认超时时间
 * 返回：字典形式
 *      resultCode：6666-成功，5555-超时，4444-失败，3344-参数异常，2222-无网络，1111-无SIM卡，6668-登录按钮事件，6669-切换到其他方式按钮事件
 *      token：一键登录token
 *      msg：文案或错误提示
 */

- (void)getLoginTokenWithController:(UIViewController *_Nonnull)vc model:(TXCustomModel *_Nullable)model timeout:(NSTimeInterval )timeout complete:(void (^_Nullable)(NSDictionary * _Nonnull resultDic))complete;

/**
 *  手动隐藏获取登录Token之后的等待动画，默认为自动隐藏，当设置 TXCustomModel 实例 autoHideLoginLoading = NO 时, 需要调用该方法手动隐藏
 */
- (void)hideLoginLoading;

/**
 注销授权页，只有在客户自定义的按钮事件中调用！！
 
 @param flag 是否添加动画
 @param complete 成功返回
 */
- (void)cancelLoginVCAnimated:(BOOL)flag complete:(void (^_Nullable)(void))complete;


@end
