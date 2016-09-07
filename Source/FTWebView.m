#import "FTWebView.h"

#define HTML_ELM_CLASS @"document.documentElement.className"
#define HTML_BODY_HEIGHT @"document.body.clientHeight"
#define HTML_BODY_WIDTH @"document.body.clientWidth"

@implementation FTWebView

- (void)enableScrollingIfDocumentIsLargerThanViewport:(BOOL)byHeight;
{
  // Get the body dimensions of the document currently shown in the webview.
  NSString *js = byHeight ? HTML_BODY_HEIGHT : HTML_BODY_WIDTH;
  int clientSize = [[self stringByEvaluatingJavaScriptFromString:js] intValue];

  CGSize viewSize = self.bounds.size;
  UIEdgeInsets insets = self.scrollView.contentInset;

  // Calculate the max size (height or width) which we can show without
  // scrolling. We have to take insets into account here because we probably
  // want to prevent part of our view being obstructed by UI elements.
  //
  // For example in the case of a top inset with a toolbar:
  //
  //  |--------|
  //  |        | <- top insert overlayed with a view
  //  |--------|
  //  |        |
  //  |        | <- usable view space for the webview
  //  |        |
  //  |________|
  CGFloat maxWithoutScrolling = 0.0;
  if (byHeight) {
    maxWithoutScrolling = viewSize.height - (insets.top + insets.bottom);
  } else {
    maxWithoutScrolling = viewSize.width - (insets.left + insets.right);
  }

  // From HTML we get the size in whole points but on the iOS the size is
  // a float. Floor the float before comparison to make sure it fits.
  self.scrollView.scrollEnabled = clientSize > floor(maxWithoutScrolling);
}

- (void)enableScrollingBasedOnDocumentBodyClass;
{
  NSArray *classes = [[self HTMLElementClass] componentsSeparatedByString:@" "];
  self.scrollView.scrollEnabled = [classes containsObject:@"noscroll"];
}

- (void)setHTMLElementClass:(NSString *)className;
{
  NSString *js = [NSString stringWithFormat:@"%@ = '%@';", HTML_ELM_CLASS, className];
  [self stringByEvaluatingJavaScriptFromString:js];
}

- (NSString *)HTMLElementClass;
{
  return [self stringByEvaluatingJavaScriptFromString:HTML_ELM_CLASS];
}

@end
