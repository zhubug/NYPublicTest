//
//  UBWebViewController.h
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UBWebViewController : UIViewController <WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *URLString;

@end

NS_ASSUME_NONNULL_END
