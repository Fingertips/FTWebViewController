#import "FTWebView.h"

#define HTML_ELM_CLASS @"document.documentElement.className"

@implementation FTWebView

- (void)enableScrollingIfDocumentIsLargerThanViewport:(BOOL)byHeight;
{
  NSString *dimension = byHeight ? @"document.body.clientHeight" : @"document.body.clientWidth";
  int value = [[self stringByEvaluatingJavaScriptFromString:dimension] intValue];
  CGSize size = self.bounds.size;
  self.scrollView.scrollEnabled = value > floor(byHeight ? size.height : size.width);
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
