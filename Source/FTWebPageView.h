#import <UIKit/UIKit.h>

@class FTWebView, FTWebPageView;

@protocol FTWebPageViewDelegate <NSObject>
@optional
- (void)webPageViewDidFinishLoad:(FTWebPageView *)pageView;
- (void)webPageView:(FTWebPageView *)webPageView
   didReceiveAction:(NSString *)actionName
      withArguments:(NSDictionary *)arguments;
@end

@interface FTWebPageView : UIView <UIWebViewDelegate>

@property (weak,     nonatomic) id<FTWebPageViewDelegate> delegate;
@property (strong,   nonatomic) NSString *applicationScheme;
@property (strong,   nonatomic) NSURL *URL;
@property (readonly, nonatomic) FTWebView *webView;
@property (readonly, nonatomic) NSString *title;
@property (assign,   nonatomic) NSInteger pageIndex;
@property (assign,   nonatomic) BOOL hasShadow;
@property (assign,   nonatomic) BOOL openExternalLinksOutsideApp;

- (void)scrollToTop;
- (void)setHTMLElementClass:(NSString *)className;

@end
