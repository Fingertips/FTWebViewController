#import <UIKit/UIKit.h>

@interface FTWebView : UIWebView

// If `byHeight` is `YES` and the document is taller than the viewport then
// scrolling is enabled. If `byHeight` is `NO` then the same applies, except
// the width of document is used.
//
// This is used to ensure that documents that don’t need scrolling won’t bounce.
- (void)enableScrollingIfDocumentIsLargerThanViewport:(BOOL)byHeight;

- (void)setHTMLElementClass:(NSString *)className;
- (NSString *)HTMLElementClass;

@end
