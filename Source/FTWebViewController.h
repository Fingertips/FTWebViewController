#import <UIKit/UIKit.h>
#import "FTWebPageView.h"

@class FTWebViewController, StyledPageControl;

@protocol FTWebViewControllerDelegate <NSObject>
@optional

- (void)webViewControllerDidLoadFirstPage:(FTWebViewController *)webViewController;

- (NSString *)webViewController:(FTWebViewController *)webViewController
      willChangeClassOfPageView:(FTWebPageView *)pageView
                        toClass:(NSString *)className;

- (void)webViewController:(FTWebViewController *)webViewController
         didReceiveAction:(NSString *)actionName
            withArguments:(NSDictionary *)arguments;

@end

@interface FTWebViewController : UIViewController <UIScrollViewDelegate, FTWebPageViewDelegate>

@property (readonly, nonatomic) NSArray *URLs;
@property (readonly, nonatomic) NSString *applicationScheme;
@property (readonly, nonatomic) UIScrollView *pagingScrollView;
@property (strong,   nonatomic) StyledPageControl *pageControl;
@property (readonly, nonatomic) NSInteger currentPageIndex;
@property (readonly, nonatomic) NSUInteger numberOfPages;
@property (readonly, nonatomic) BOOL isAtFirstPage;
@property (readonly, nonatomic) BOOL isAtLastPage;

@property (assign,   nonatomic) CGFloat pageMargin;
@property (assign,   nonatomic) BOOL hasPageMarginShadow;
@property (assign,   nonatomic) BOOL openExternalLinksOutsideApp;
@property (weak,     nonatomic) id<FTWebViewControllerDelegate> delegate;

- (id)initWithPageURLs:(NSArray *)URLs;
- (id)initWithPageURLs:(NSArray *)URLs applicationScheme:(NSString *)applicationScheme;

- (void)loadPageAtIndex:(NSInteger)index;
- (void)loadNextPage;
- (void)loadPreviousPage;

- (FTWebPageView *)previousPageView;
- (FTWebPageView *)currentPageView;
- (FTWebPageView *)nextPageView;

@end
