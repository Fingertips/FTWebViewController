#import <UIKit/UIKit.h>

typedef NS_ENUM(int, FTWebPageViewConditionalScrolling) {
  FTWebPageViewConditionalScrollingNever    = 0,
  FTWebPageViewConditionalScrollingByHeight = 1,
  FTWebPageViewConditionalScrollingByWidth  = 2
};

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
@property (assign,   nonatomic) FTWebPageViewConditionalScrolling conditionalScrolling;
@property (assign,   nonatomic) BOOL scrollEnabled;
@property (assign,   nonatomic) BOOL showLoadingIndicator;
@property (assign,   nonatomic) Class webViewClass;

+ (NSString *)defaultApplicationScheme;
+ (void)setDefaultApplicationScheme:(NSString *)applicationScheme;

+ (void)extractAction:(NSString **)action arguments:(NSDictionary **)arguments fromURL:(NSURL *)URL;

- (void)scrollToTop;
- (void)setHTMLElementClass:(NSString *)className;

- (void)setWebViewContentInsets:(UIEdgeInsets)insets;

@end
