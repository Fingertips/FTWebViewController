#import "FTWebPageView.h"
#import "FTWebView.h"

#import <QuartzCore/QuartzCore.h>

@interface FTWebPageView ()
@property (strong,   nonatomic) FTWebView *webView;
@property (strong,   nonatomic) UIActivityIndicatorView *activityIndicator;
@property (readonly, nonatomic) UIScrollView *scrollView;
@end

@implementation FTWebPageView

@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame;
{
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor lightGrayColor];

    _hasShadow = NO;
    _openExternalLinksOutsideApp = YES;

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self addSubview:_activityIndicator];

    _webView = [[FTWebView alloc] initWithFrame:self.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    // This has to be enabled so that the webview automatically resizes the
    // content after orientation changes.
    _webView.scalesPageToFit = YES;
    [self addSubview:_webView];
  }
  return self;
}

- (void)setHasShadow:(BOOL)flag;
{
  if (_hasShadow != flag) {
    _hasShadow = flag;
    if (_hasShadow) {
      self.layer.shadowOpacity = 0.7;
      self.layer.shadowOffset  = CGSizeMake(0.0, 0.0);
      self.layer.shadowRadius  = 4.0;
      self.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    } else {
      self.layer.shadowOpacity = 0.0;
    }
  }
}

- (void)setApplicationScheme:(NSString *)scheme;
{
  if (![_applicationScheme isEqualToString:scheme]) {
    _applicationScheme = [scheme lowercaseString];
  }
}

- (void)layoutSubviews;
{
  CGPoint center = self.center;
  center.x -= self.frame.origin.x;
  self.activityIndicator.center = center;

  // Force the size of the webView, because it doesn't resize with the superview
  // if it has been removed from the superview at the time the superview resizes.
  self.webView.frame = self.bounds;

  [self.webView enableScrollingIfDocumentIsLargerThanViewport];
}

- (UIScrollView *)scrollView;
{
  if (_scrollView == nil) {
    _scrollView = [self.webView findNestedScrollView];
  }
  return _scrollView;
}

- (NSString *)title;
{
  return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)setHTMLElementClass:(NSString *)className;
{
  self.webView.HTMLElementClass = className;
}

- (void)scrollToTop;
{
  self.scrollView.contentOffset = CGPointZero;
}

// When a page is loaded, the webview is removed from the view and is only
// added again once the webview is done loading. This ensures that when paging
// fast, the user will never see an already loaded page on the wrong page.
//
// See webViewDidFinishLoad:
- (void)setURL:(NSURL *)URL {
  if (![URL isEqual:_URL]) {
    _URL = URL;
    [self.activityIndicator startAnimating];
    [self.webView removeFromSuperview];
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)_
{
  [self.webView enableScrollingIfDocumentIsLargerThanViewport];
  // Now that the webview has been loaded we can show it again.
  [self addSubview:self.webView];
  [self.activityIndicator stopAnimating];
  if ([self.delegate respondsToSelector:@selector(webPageViewDidFinishLoad:)]) {
    [self.delegate webPageViewDidFinishLoad:self];
  }
}

- (BOOL)webView:(UIWebView *)_ shouldStartLoadWithRequest:(NSURLRequest *)request
                                           navigationType:(UIWebViewNavigationType)navigationType;
{
  NSURL *URL = request.URL;
  id<FTWebPageViewDelegate> delegate = self.delegate;
  if (delegate && [self.applicationScheme isEqualToString:URL.scheme] &&
      [delegate respondsToSelector:@selector(webPageView:didReceiveAction:withArguments:)]) {
    NSString *actionName = URL.host;
    NSArray *pairs = [URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *arguments = [NSMutableDictionary new];
    if ([URL.query length] > 0) {
      for (NSString *pair in pairs) {
        NSArray *nameAndValue = [pair componentsSeparatedByString:@"="];
        NSString *value = nameAndValue[1];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        arguments[nameAndValue[0]] = value;
      }
    }
    [self.delegate webPageView:self didReceiveAction:actionName withArguments:[arguments copy]];
    return NO;
  }

  if (self.openExternalLinksOutsideApp && navigationType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
  }

  return YES;
}

@end
