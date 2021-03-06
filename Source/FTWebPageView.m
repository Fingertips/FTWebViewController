#import "FTWebPageView.h"
#import "FTWebView.h"

#import <QuartzCore/QuartzCore.h>

@interface FTWebPageView ()
@property (strong,   nonatomic) FTWebView *webView;
@property (strong,   nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation FTWebPageView

@synthesize applicationScheme = _applicationScheme;

static NSString *_defaultApplicationScheme = nil;

+ (NSString *)defaultApplicationScheme;
{
  return _defaultApplicationScheme;
}

+ (void)setDefaultApplicationScheme:(NSString *)applicationScheme;
{
  _defaultApplicationScheme = [applicationScheme lowercaseString];
}

- (id)initWithFrame:(CGRect)frame;
{
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor lightGrayColor];

    _hasShadow = NO;
    _scrollEnabled = YES;
    _showLoadingIndicator = YES;
    _conditionalScrolling = FTWebPageViewConditionalScrollingByBodyClass;
    _openExternalLinksOutsideApp = YES;

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.hidesWhenStopped = YES;
    [self addSubview:_activityIndicator];

    _webViewClass = [FTWebView class];
  }
  return self;
}

- (FTWebView *)webView;
{
  if (_webView == nil) {
    _webView = [[self.webViewClass alloc] initWithFrame:self.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.opaque = NO;
    _webView.delegate = self;
    // This has to be enabled so that the webview automatically resizes the
    // content after orientation changes.
    _webView.scalesPageToFit = YES;
    [self addSubview:_webView];
  }
  return _webView;
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

- (void)setScrollEnabled:(BOOL)flag;
{
  if (_scrollEnabled != flag) {
    _scrollEnabled = flag;
    UIScrollView *scrollView = self.webView.scrollView;
    scrollView.bounces = flag;
    scrollView.scrollEnabled = flag;
  }
}

- (void)setApplicationScheme:(NSString *)scheme;
{
  if (![_applicationScheme isEqualToString:scheme]) {
    _applicationScheme = [scheme lowercaseString];
  }
}

- (NSString *)applicationScheme;
{
  return _applicationScheme ?: [[self class] defaultApplicationScheme];
}

- (void)setWebViewContentInsets:(UIEdgeInsets)insets;
{
  NSAssert(insets.left == 0 && insets.right == 0, @"This shortcut only supports top and bottom insets.");
  UIScrollView *scrollView = self.webView.scrollView;
  scrollView.contentInset = insets;
  scrollView.scrollIndicatorInsets = insets;
}

- (void)updateConditionalScrolling;
{
  if (self.scrollEnabled && self.conditionalScrolling != FTWebPageViewConditionalScrollingNever) {
    if (self.conditionalScrolling == FTWebPageViewConditionalScrollingByHeight)
      [self.webView enableScrollingIfDocumentIsLargerThanViewport:true];
    else if (self.conditionalScrolling == FTWebPageViewConditionalScrollingByWidth)
      [self.webView enableScrollingIfDocumentIsLargerThanViewport:false];
    else if (self.conditionalScrolling == FTWebPageViewConditionalScrollingByBodyClass)
      [self.webView enableScrollingBasedOnDocumentBodyClass];
  }
}

- (void)layoutSubviews;
{
  CGPoint center = self.center;
  center.x -= self.frame.origin.x;
  self.activityIndicator.center = center;

  // The webview does not automatically resize together with the superview
  // then it resizes so we need to force its size. This happens for example
  // when the orientation of the app changes.
  //
  // Note that the view may become larger than its superview causing it to
  // not swipe properly. That's why we floor the width and height.
  self.webView.frame = CGRectMake(
    self.bounds.origin.x,
    self.bounds.origin.y,
    floor(self.bounds.size.width),
    floor(self.bounds.size.height)
  );

  [self updateConditionalScrolling];
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
  UIEdgeInsets insets = self.webView.scrollView.contentInset;
  CGPoint point = CGPointMake(-insets.left, -insets.top);
  self.webView.scrollView.contentOffset = point;
}

// When a page is loaded, the webview is removed from the view and is only
// added again once the webview is done loading. This ensures that when paging
// fast, the user will never see an already loaded page on the wrong page.
//
// See webViewDidFinishLoad:
- (void)setURL:(NSURL *)URL {
  if (![URL isEqual:_URL]) {
    _URL = URL;
    if (self.showLoadingIndicator) [self.activityIndicator startAnimating];
    [self.webView removeFromSuperview];
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)_
{
  [self updateConditionalScrolling];
  // Now that the webview has been loaded we can show it again.
  [self addSubview:self.webView];
  [self.activityIndicator stopAnimating];
  if ([self.delegate respondsToSelector:@selector(webPageViewDidFinishLoad:)]) {
    [self.delegate webPageViewDidFinishLoad:self];
  }
}

+ (void)extractAction:(NSString **)action arguments:(NSDictionary **)arguments fromURL:(NSURL *)URL;
{
  NSString *actionName = URL.host;
  NSArray *pairs = [URL.query componentsSeparatedByString:@"&"];
  NSMutableDictionary *args = [NSMutableDictionary new];
  if ([URL.query length] > 0) {
    for (NSString *pair in pairs) {
      NSArray *nameAndValue = [pair componentsSeparatedByString:@"="];
      NSString *value = nameAndValue[1];
      value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      args[nameAndValue[0]] = value;
    }
  }
  *action = actionName;
  *arguments = [args copy];
}

- (BOOL)webView:(UIWebView *)_ shouldStartLoadWithRequest:(NSURLRequest *)request
                                           navigationType:(UIWebViewNavigationType)navigationType;
{
  NSURL *URL = request.URL;
  id<FTWebPageViewDelegate> delegate = self.delegate;
  if (delegate && [self.applicationScheme isEqualToString:URL.scheme] &&
      [delegate respondsToSelector:@selector(webPageView:didReceiveAction:withArguments:)]) {
    NSString *action = nil;
    NSDictionary *arguments = nil;
    [[self class] extractAction:&action arguments:&arguments fromURL:URL];
    [self.delegate webPageView:self didReceiveAction:action withArguments:arguments];
    return NO;
  }

  if (self.openExternalLinksOutsideApp && navigationType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
  }

  return YES;
}

@end
