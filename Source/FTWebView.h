#import <UIKit/UIKit.h>

@interface FTWebView : UIWebView

- (void)enableScrollingIfDocumentIsLargerThanViewport;

- (void)setHTMLElementClass:(NSString *)className;
- (NSString *)HTMLElementClass;

@end
