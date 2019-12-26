//
//  UBWebViewController.m
//

#import "UBWebViewController.h"
#import "NYMobClickHeader.h"

@interface UBWebViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIProgressView *loadingProgressView;
@property (nonatomic, strong) UIButton *reloadButton;

@end

@implementation UBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.bounces = NO;
    self.navigationController.navigationBar.translucent = NO;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.preferences = [[WKPreferences alloc] init];
    config.userContentController = [[WKUserContentController alloc]init];
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
    [self setModalPresentationStyle:UIModalPresentationFullScreen];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 10.0, *)) {
        _webView.scrollView.refreshControl = self.refreshControl;
    }
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

    [self.view addSubview:_webView];
    [self.view addSubview:self.loadingProgressView];
//    [self.view addSubview:self.reloadButton];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.hidesWhenStopped = YES;
    
    [self loadWebView];
}


- (void)loadWebView {
    if (_URLString) {
        if ([_URLString hasPrefix:@"www"]) {
            _URLString = [@"http://" stringByAppendingString:_URLString];
        }

        NSURL * URL = [NSURL URLWithString:[_URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        NYLog(@"%@",URL.absoluteString);
       
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        [self.webView loadRequest:request];
    }
}
- (void)stopActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self stopActivity];
    webView.hidden = YES;
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self stopActivity];
    webView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _activityView.center = self.view.center;
    [self.view addSubview:_activityView];
    [_activityView startAnimating];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self stopActivity];
    [_refreshControl endRefreshing];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        _loadingProgressView.progress = [change[@"new"] floatValue];
        if (_loadingProgressView.progress == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self->_loadingProgressView.hidden = YES;
            });
        }
    }
}
- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView stopLoading];
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;
}
- (UIProgressView*)loadingProgressView {
    if (!_loadingProgressView) {
        _loadingProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        _loadingProgressView.progressTintColor = [UIColor redColor];
    }
    return _loadingProgressView;
}
- (UIRefreshControl*)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc]init];
        [_refreshControl addTarget:self action:@selector(webViewReload) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}
- (void)webViewReload {
    [_webView reload];
}
- (UIButton*)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.frame = CGRectMake(0, 0, 150, 150);
        _reloadButton.center = self.view.center;
        _reloadButton.layer.cornerRadius = 75.0;
        [_reloadButton setBackgroundImage:[UIImage imageNamed:@"sure_placeholder_error"] forState:UIControlStateNormal];
        [_reloadButton setTitle:@"您的网络有问题，请检查您的网络设置" forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_reloadButton setTitleEdgeInsets:UIEdgeInsetsMake(200, -50, 0, -50)];
        _reloadButton.titleLabel.numberOfLines = 0;
        _reloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        CGRect rect = _reloadButton.frame;
        rect.origin.y -= 100;
        _reloadButton.frame = rect;
        _reloadButton.enabled = NO;
    }
    return _reloadButton;
}

@end
