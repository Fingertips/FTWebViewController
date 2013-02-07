#import "FTWebView.h"

#define HTML_ELM_CLASS @"document.documentElement.className"

@implementation FTWebView

- (UIScrollView *)findNestedScrollView;
{
  NSArray *subviews = self.subviews;
  for (UIView *subview in subviews) {
    if ([subview isKindOfClass:[UIScrollView class]]) {
      return (UIScrollView *)subview;
    }
  }
  NSLog(@"[!] Unable to find nested scrollview in FTWebView: %@", self);
  return nil;
}

- (void)enableScrollingIfDocumentIsLargerThanViewport;
{
  UIScrollView *scrollView = [self findNestedScrollView];
  if (scrollView == nil) return;
  // Completely disable scrolling when the page is shorter than the viewport.
  // This ensures that the page doesn't bounce when the user tries to scroll.
  int height = [[self stringByEvaluatingJavaScriptFromString:@"document.height"] intValue];
  scrollView.scrollEnabled = height > floor(self.bounds.size.height);
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
