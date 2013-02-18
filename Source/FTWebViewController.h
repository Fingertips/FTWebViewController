#import <UIKit/UIKit.h>
#import "FTWebPageView.h"

@class FTWebViewController;

@protocol FTWebViewControllerDelegate <NSObject>
@optional

- (void)webViewControllerDidLoadFirstPage:(FTWebViewController *)webViewController;

- (void)webViewController:(FTWebViewController *)webViewController
          didShowPageView:(FTWebPageView *)pageView;

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
@property (strong,   nonatomic) UIPageControl *pageControl;
@property (readonly, nonatomic) NSInteger currentPageIndex;
@property (readonly, nonatomic) NSUInteger numberOfPages;
@property (readonly, nonatomic) BOOL isAtFirstPage;
@property (readonly, nonatomic) BOOL isAtLastPage;

@property (assign,   nonatomic) CGFloat pageMargin;
@property (assign,   nonatomic) BOOL hasPageMarginShadow;
@property (assign,   nonatomic) BOOL horizontalLayout;
@property (assign,   nonatomic) BOOL openExternalLinksOutsideApp;
@property (assign,   nonatomic) BOOL hasPageNavigationButtons;
@property (assign,   nonatomic) BOOL hasPageControl;
@property (weak,     nonatomic) id<FTWebViewControllerDelegate> delegate;

- (id)initWithPageURLs:(NSArray *)URLs;
- (id)initWithPageURLs:(NSArray *)URLs applicationScheme:(NSString *)applicationScheme;

- (void)loadPageAtIndex:(NSInteger)index;
- (void)loadPageAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)loadNextPage;
- (void)loadNextPage:(BOOL)animated;
- (void)loadPreviousPage;
- (void)loadPreviousPage:(BOOL)animated;

- (FTWebPageView *)previousPageView;
- (FTWebPageView *)currentPageView;
- (FTWebPageView *)nextPageView;

@end
