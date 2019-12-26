//
//  TaskViewController.m
//

#import "TaskViewController.h"
#import "UBFunctionManager.h"
#import <MJExtension/MJExtension.h>
#import <UMShare/UMShare.h>
#import <WXApi.h>
#import "UBDeviceInfo.h"
#import "WkWebViewScriptMessageDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "NYMobClickHeader.h"
#import <UMAnalytics/MobClick.h>
#import "ZNYBundleManager.h"

//登录
#define tokenLogin                  @"tokenLogin"
//获取手机号验证信息
#define checkPhone                  @"checkPhone"
//打开应用
#define jumpApp                     @"jumpApp"
//返回某个app是否安装和试玩时间
#define appTime                     @"appTime"
//跳转AppStore
#define jumpAppStore                @"jumpAppStore"
//分享
#define share                       @"share"
// 安装描述文件
#define dowloadUdidConfig           @"dowloadUdidConfig"


static NSString * const FuncNameLogin = @"tokenLogin";

@interface TaskViewController ()<WKScriptMessageHandler>

@property (nonatomic,strong) UIButton *refreshBtn;
@property (strong, nonatomic) AVAudioSession *session;
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation TaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"赚钱宝";
    // 添加刷新按钮
    [self setupRereshBtn];
    // 监听JS回调
    [self addScriptMessageHandler];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessCodeCallback) name:@"checkPhoneSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUDID) name:@"updateUDID" object:nil];
    [self playMP3];
    
}
- (void)playMP3 {
    self.session = [AVAudioSession sharedInstance];
    /*打开应用会关闭别的播放器音乐*/
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    /*打开应用不影响别的播放器音乐*/
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [self.session setActive:YES error:nil];
    //设置代理 可以处理电话打进时中断音乐播
//    [self.session setDelegate:self];
    NSString *musicPath = [ZNYBundleManager getFilePathFromBundle:@"jinyin.mp3"];
    NSURL *URLPath = [[NSURL alloc] initFileURLWithPath:musicPath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:URLPath error:nil];
    [_player prepareToPlay];
    //[_player setDelegate:self];
    _player.numberOfLoops = -1;
    [_player play];
}

//! 为userContentController添加ScriptMessageHandler，并指明name
- (void)addScriptMessageHandler {
    WKUserContentController *userCC = self.webView.configuration.userContentController;
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:@"log"];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:tokenLogin];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:checkPhone];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:appTime];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:jumpApp];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:jumpAppStore];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:share];
      [userCC addScriptMessageHandler:[[WkWebViewScriptMessageDelegate alloc] initWithDelegate:self] name:dowloadUdidConfig];
}

- (void)setupRereshBtn {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *path = [ZNYBundleManager getFilePathFromBundle:@"refresh"];
    [button setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0,20, 20);
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    _refreshBtn = button;
}
- (void)refreshBtnClick:(UIButton *)btn {
    [MobClick event:mob_homepageRefreshBtnClick];
    [self refresh];
}
- (void)refresh {
    [self.webView reload];
}
- (void)startAnimation {
    // 开始旋转
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    rotationAnimation.duration = 0.5;
    //防止动画结束回到原始位置
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.repeatCount = 10;//重复次数
    [self.refreshBtn.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
- (void)endAnimation {
    // 返回原来位置
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnimation.duration = 0.5;
    //防止动画结束回到原始位置
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.repeatCount = 0;//重复次数
    //注意一定要是rotationAnimation2不然会很快
    [self.refreshBtn.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation2"];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"installUDID"]) {
        [self refresh];
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self startAnimation];
    [super webView:webView didStartProvisionalNavigation:navigation];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [super webView:webView didFinishNavigation:navigation];
    [self endAnimation];
}
#pragma mark WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

    if ([@"log" isEqualToString:message.name]) {
        NYLog(@"log:%@",message.body);
    }
    if ([tokenLogin isEqualToString:message.name]) {
        [self tokenLoginCallback];
    }
    if ([checkPhone isEqualToString:message.name]) {
        NSString *phoneNum = message.body;
        if (phoneNum.length == 11) {
            [UBFunctionManager setPhoneNumToken:phoneNum];
        }
    }
    if ([jumpApp isEqualToString:message.name]) {
        [self jumpAppCallback:message.body];
    }
    if ([appTime isEqualToString:message.name]) {
        NSString *status = [UBFunctionManager jumpAppOpenAppWithBundleID:message.body];
        BOOL installed = [UBDeviceInfo isAppInstalled:message.body];
        if ([status isEqualToString:@"以安装"] && installed) {
            [self appTimeCallback:message.body];
        }
    }
    if ([jumpAppStore isEqualToString:message.name]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/search"]];
    }
    if ([dowloadUdidConfig isEqualToString:message.name]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"installUDID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"设备验证" message:@"为了保障您的利益，赚钱宝需对您的设备进行验证，点击去验证会跳转Safari浏览器,点击允许,去手机设置页面安装证书即可" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"去验证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MobClick event:mob_getUDID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://zqb.ubangok.com/cloud/ubang/udid/newgetconfig"]];
        }];
        [alertVc addAction:action];
        MJWeakSelf;
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"已验证" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf refresh];
        }];
        [alertVc addAction:cancle];

        [self presentViewController:alertVc animated:YES completion:nil];
    }
    if ([share isEqualToString:message.name]) {
        NSDictionary *dict = message.body;
        NSString *parentID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"parent_id"]];
        NSString *num = [NSString stringWithFormat:@"%@",[dict objectForKey:@"num"]];
        NSString *palte = [NSString stringWithFormat:@"%@",[dict objectForKey:@"palte"]];;
        UMSocialPlatformType type;
        if ([palte isEqualToString:@"1"]) {
            type = UMSocialPlatformType_WechatSession;
        }else{
            type = UMSocialPlatformType_WechatTimeLine;
        }
        [self shareWithPlatform:type parentID:parentID number:num];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString * requestStr = navigationAction.request.URL.absoluteString;
    NYLog(@"%@",requestStr);
    if ([requestStr containsString:@""]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)receiveNotification:(NSNotification *)noti {
    // NSNotification 有三个属性，name, object, userInfo，其中最关键的object就是从第三个界面传来的数据。name就是通知事件的名字， userInfo一般是事件的信息。
    NYLog(@"%@ === %@ === %@", noti.object, noti.userInfo, noti.name);
    NSDictionary *dict = (NSDictionary *)noti.object;
    if ([self isVisible]) {
    
        int64_t delayInSeconds = 0.5;      // 延迟的时间
        /*
         *@parameter 1,时间参照，从此刻开始计时
         *@parameter 2,延时多久，此处为秒级，还有纳秒等。10ull * NSEC_PER_MSEC
         */
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // do something
            if ([dict[@"sharaPlatform"] isEqualToString:@"1"])
            {
                [self shareWithPlatform:UMSocialPlatformType_WechatSession parentID:dict[@"parentID"] number:dict[@"num"]];
                [MobClick event:mob_shareToWx];
            }else{
                [MobClick event:mob_shareToFriendly];
                [self shareWithPlatform:UMSocialPlatformType_WechatTimeLine parentID:dict[@"parentID"] number:dict[@"num"]];
            }
        });
    }
}
- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
}
- (void)shareWithPlatform:(UMSocialPlatformType)platform
                 parentID:(NSString *)parent
                   number:(NSString *)num {
        NSString *shareTitle = nil;
        NSString *shareURL = nil;
    
        if (num.length > 0 && parent.length > 0) {
            shareTitle = [NSString stringWithFormat:@"我在友榜赚钱宝已经赚了%@元，一起来玩吧。",num];
            shareURL = [NSString stringWithFormat:@"https://zqb.ubangok.com/new/#/starePage?parent_id=%@&num=%@",parent, num];
        } else {
            return;
        }
 
    NSString *path = [ZNYBundleManager getFilePathFromBundle:@"AppIcon"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:@"好玩有趣又简单" thumImage:image];

    shareObject.webpageUrl = shareURL;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;

    [[UMSocialManager defaultManager] shareToPlatform:platform messageObject:messageObject currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            NYLog(@"share error = %@", error);
        }
    }];
}

- (void)appTimeCallback:(NSString *)bundleId {
    NSString * jsTitle1 = [NSString stringWithFormat:@"appTimeCallback('%@')",@{@"installed":@1}.mj_JSONString];
   
    [self.webView evaluateJavaScript:jsTitle1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        NYLog(@"result:%@ ,error:%@",result, error);
    }];
}
- (void)jumpAppCallback:(NSString *)bundleId {
    if (![bundleId isKindOfClass:[NSString class]] && ![bundleId isKindOfClass:[NSNull class]] && ![bundleId isEqualToString:@"(null)"]) {
        NYLog(@"bundleId不是字符串");
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    NSString *status = [UBFunctionManager jumpAppOpenAppWithBundleID:bundleId];
    [params setObject:status forKey:@"status"];
    NSString * jsTitle1 = [NSString stringWithFormat:@"jumpAppCallback('%@')",params.mj_JSONString];
    [self.webView evaluateJavaScript:jsTitle1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//     NSLog(@"result:%@ ,error:%@",result, error);
    }];
}
- (void)checkPhoneCallback {
    NSString * jsTitle1 = [NSString stringWithFormat:@"checkPhoneCallback('%@')",@{@"status":@"OK"}.mj_JSONString];
    [self.webView evaluateJavaScript:jsTitle1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
    }];
}
- (void)accessCodeCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = [UBFunctionManager actionWithAccessCodeQuery];
        NSString * jsTitle1 = [NSString stringWithFormat:@"accessCodeCallback('%@')",info.mj_JSONString];
        [self.webView evaluateJavaScript:jsTitle1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            NSLog(@"result:%@ ,error:%@",result, error);
        }];
    });
}
- (void)tokenLoginCallback {
    NSDictionary *info = [UBFunctionManager getInfoWithBundleID:@""];
    NYLog(@"登录信息：%@",info);
    NSString * jsTitle1 = [NSString stringWithFormat:@"tokenLoginCallback('%@')",info.mj_JSONString];
    [self.webView evaluateJavaScript:jsTitle1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        [MobClick event:mob_userTokenLogin];
//     NSLog(@"result:%@ ,error:%@",result, error);
    }];
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}
- (void)updateUDID {
    NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    if (udid) {
        NSString * jsTitle1 = [NSString stringWithFormat:@"udidcallback('%@')",@{@"udid":udid}.mj_JSONString];
        [self.webView evaluateJavaScript:jsTitle1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            [MobClick event:mob_checkUDID];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"installUDID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
//         NSLog(@"result:%@ ,error:%@",result, error);
        }];
    }
}

@end
