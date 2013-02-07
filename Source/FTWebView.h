#import <UIKit/UIKit.h>

@interface FTWebView : UIWebView

- (UIScrollView *)findNestedScrollView;
- (void)enableScrollingIfDocumentIsLargerThanViewport;

- (void)setHTMLElementClass:(NSString *)className;
- (NSString *)HTMLElementClass;

@end
