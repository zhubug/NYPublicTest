//
//  WXLoginViewController.m
//
//

#import "WXLoginViewController.h"
#import "ZNYBundleManager.h"
#import <UMShare/UMShare.h>
#import "TaskViewController.h"
#import <WXApi.h>
#import "NYMobClickHeader.h"
#import <UMAnalytics/MobClick.h>

@interface WXLoginViewController ()

@end

@implementation WXLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) initUI{
    
    NSString *pic1Path = [ZNYBundleManager getFilePathFromBundle:@"bg"];
    UIImageView *bgView = [[UIImageView alloc]init];
    bgView.image = [UIImage imageWithContentsOfFile:pic1Path];
    bgView.userInteractionEnabled = YES;
    
    [self.view addSubview:bgView];
    bgView.frame = self.view.bounds;
    
    NSString *pic2Path = [ZNYBundleManager getFilePathFromBundle:@"safe"];
    UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:pic2Path]];
    [logo sizeToFit];
    logo.contentMode = UIViewContentModeCenter;
    [bgView addSubview:logo];
    logo.center = CGPointMake(self.view.center.x, 200);
        
    UIButton *wechatBtn = [[UIButton alloc]init];
    wechatBtn.backgroundColor = [UIColor yellowColor];
    [wechatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [wechatBtn setTitle:@"微信授权登录" forState:UIControlStateNormal];
    [wechatBtn addTarget:self action:@selector(wechatBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    wechatBtn.layer.cornerRadius = 26;
    [bgView addSubview:wechatBtn];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;

    logo.frame = CGRectMake(screenW * 0.5 - 55, 108, 110, 100);
    
    wechatBtn.frame = CGRectMake(screenW * 0.5 - 110, screenH - 200 , 220, 58);

    
}

-(void)wechatBtnDidClick
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        NYLog(@"111111");
        if (error) {
            NYLog(@"%@",error);
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NYLog(@"Wechat uid: %@", resp.uid);
            NYLog(@"Wechat openid: %@", resp.openid);
            NYLog(@"Wechat unionid: %@", resp.unionId);
            NYLog(@"Wechat accessToken: %@", resp.accessToken);
            NYLog(@"Wechat refreshToken: %@", resp.refreshToken);
            NYLog(@"Wechat expiration: %@", resp.expiration);

            // 用户信息
            NYLog(@"Wechat name: %@", resp.name);
            NYLog(@"Wechat iconurl: %@", resp.iconurl);
            NYLog(@"Wechat gender: %@", resp.unionGender);
            NSUserDefaults *userdafault = [NSUserDefaults standardUserDefaults];
            [userdafault setObject:resp.openid forKey:@"openid"];
            [userdafault setObject:resp.name forKey:@"name"];
            [userdafault setObject:resp.iconurl forKey:@"iconurl"];
            [userdafault setObject:resp.unionGender forKey:@"unionGender"];
            [userdafault setObject:resp.unionId forKey:@"unionId"];
            [userdafault synchronize];
            // 第三方平台SDK源数据
            NYLog(@"Wechat originalResponse: %@", resp.originalResponse);
            [MobClick event:mob_wxLogin attributes:@{@"openid":resp.openid}];
            TaskViewController *vc = [TaskViewController new];
            vc.URLString = self.domin;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        }
    }];

}

@end
