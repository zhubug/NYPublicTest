
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WkWebViewScriptMessageDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic,weak)id <WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
