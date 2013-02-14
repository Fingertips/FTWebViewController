#import "FTWebView.h"

#define HTML_ELM_CLASS @"document.documentElement.className"

@implementation FTWebView

- (void)enableScrollingIfDocumentIsLargerThanViewport;
{
  // Completely disable scrolling when the page is shorter than the viewport.
  // This ensures that the page doesn't bounce when the user tries to scroll.
  int height = [[self stringByEvaluatingJavaScriptFromString:@"document.height"] intValue];
  self.scrollView.scrollEnabled = height > floor(self.bounds.size.height);
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
