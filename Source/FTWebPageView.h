#import <UIKit/UIKit.h>

@class FTWebView, FTWebPageView;

@protocol FTWebPageViewDelegate
- (void)pageViewDidFinishLoad:(FTWebPageView *)pageView;
- (BOOL)pageView:(FTWebPageView *)pageView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@end

@interface FTWebPageView : UIView <UIWebViewDelegate>

@property (weak,     nonatomic) id<FTWebPageViewDelegate> delegate;
@property (strong,   nonatomic) NSURL *URL;
@property (readonly, nonatomic) FTWebView *webView;
@property (readonly, nonatomic) NSString *title;
@property (assign,   nonatomic) NSInteger pageIndex;
@property (assign,   nonatomic) BOOL hasShadow;

- (void)scrollToTop;
- (void)setHTMLElementClass:(NSString *)className;

@end
