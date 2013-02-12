#import "FTWebViewController.h"
#import "FTWebView.h"

#import "StyledPageControl.h"
#import <QuartzCore/QuartzCore.h>

@interface FTWebViewController ()
@property (strong, nonatomic) UIScrollView *pagingScrollView;
@property (strong, nonatomic) NSMutableArray *pageViews;
@property (strong, nonatomic) UISegmentedControl *navigationButtons;
@property (assign, nonatomic) NSInteger currentPageIndex;
@property (assign, nonatomic, getter=isRotating) BOOL rotating;
@property (assign, nonatomic, getter=didNotifyDelegateThatFirstPageIsLoaded) BOOL notifiedDelegateThatFirstPageIsLoaded;
@end

@implementation FTWebViewController

#pragma mark - Public API

- (id)initWithPageURLs:(NSArray *)URLs;
{
  return [self initWithPageURLs:URLs applicationScheme:nil];
}

- (id)initWithPageURLs:(NSArray *)URLs applicationScheme:(NSString *)applicationScheme;
{
  if ((self = [super init])) {
    _URLs = [URLs copy];
    _applicationScheme = [applicationScheme lowercaseString];
    _pageMargin = 20;
    _currentPageIndex = 0;
    _hasPageMarginShadow = YES;
    _openExternalLinksOutsideApp = YES;
    _hasPageNavigationButtons = YES;
    _pageViews = [NSMutableArray new];
  }
  return self;
}

- (void)setHasPageMarginShadow:(BOOL)flag;
{
  if (_hasPageMarginShadow != flag) {
    _hasPageMarginShadow = flag;
    for (FTWebPageView *pageView in self.pageViews) {
      pageView.hasShadow = flag;
    }
  }
}

- (void)setOpenExternalLinksOutsideApp:(BOOL)flag;
{
  if (_openExternalLinksOutsideApp != flag) {
    _openExternalLinksOutsideApp = flag;
    for (FTWebPageView *pageView in self.pageViews) {
      pageView.openExternalLinksOutsideApp = flag;
    }
  }
}

- (void)setApplicationScheme:(NSString *)scheme;
{
  if (![_applicationScheme isEqualToString:scheme]) {
    _applicationScheme = scheme;
    for (FTWebPageView *pageView in self.pageViews) {
      pageView.applicationScheme = scheme;
    }
  }
}

- (NSUInteger)numberOfPages;
{
  return [self.URLs count];
}

- (void)loadPageAtIndex:(NSInteger)index;
{
  [self _loadPageAtIndex:index];
  CGFloat offset = self.currentPageView.frame.origin.x - (self.pageMargin / 2);
  self.pagingScrollView.contentOffset = CGPointMake(offset, 0);
  [self scrollViewDidEndDecelerating:nil]; // TODO HACK
}

- (void)loadNextPage;
{
  [self loadPageAtIndex:self.currentPageIndex + 1];
}

- (void)loadPreviousPage;
{
  [self loadPageAtIndex:self.currentPageIndex - 1];
}

- (BOOL)isAtFirstPage;
{
  return self.currentPageIndex == 0;
}

- (BOOL)isAtLastPage;
{
  return self.currentPageIndex == self.URLs.count-1;
}

#pragma mark - Private from here on

- (void)loadView;
{
  CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
  self.view = [[UIView alloc] initWithFrame:viewFrame];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  viewFrame.origin = CGPointZero;

  CGRect scrollViewFrame = CGRectMake(
    -(self.pageMargin / 2),
    0,
    viewFrame.size.width + self.pageMargin,
    viewFrame.size.height
  );
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
  scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.delegate = self;
  scrollView.alwaysBounceHorizontal = YES;
  scrollView.pagingEnabled = YES;
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.layer.masksToBounds = NO;
  self.pagingScrollView = scrollView;
  [self.view addSubview:scrollView];

  self.pageViews = [NSMutableArray array];
  for (int i = 0; i < 3; i++) {
    FTWebPageView *pageView = [[FTWebPageView alloc] initWithFrame:viewFrame];
    pageView.delegate = self;
    pageView.applicationScheme = self.applicationScheme;
    pageView.hasShadow = self.hasPageMarginShadow;
    pageView.openExternalLinksOutsideApp = self.openExternalLinksOutsideApp;
    [self.pageViews addObject:pageView];
  }
  // Scrolling to left/right on the first/last pages should show the same
  // background color as the webviews on the top/bottom.
  scrollView.backgroundColor = self.currentPageView.webView.backgroundColor;

  CGRect pageControlFrame = CGRectMake(0, 0, viewFrame.size.width, 22);
  self.pageControl = [[StyledPageControl alloc] initWithFrame:pageControlFrame];
  self.pageControl.pageControlStyle = PageControlStyleDefault;
  self.pageControl.diameter = 9;
  self.pageControl.coreNormalColor = [UIColor colorWithWhite:0.5 alpha:0.3];
  self.pageControl.coreSelectedColor = [UIColor colorWithWhite:0.5 alpha:1];
  self.pageControl.userInteractionEnabled = NO;
  self.pageControl.numberOfPages = self.numberOfPages;
  [self.view addSubview:self.pageControl];

  if (self.hasPageNavigationButtons) {
    NSArray *images = @[[UIImage imageNamed:@"button-left"], [UIImage imageNamed:@"button-right"]];
    self.navigationButtons = [[UISegmentedControl alloc] initWithItems:images];
    self.navigationButtons.momentary = YES;
    self.navigationButtons.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.navigationButtons addTarget:self
                              action:@selector(changePage:)
                    forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *buttonsItem = [[UIBarButtonItem alloc] initWithCustomView:self.navigationButtons];
    self.navigationItem.rightBarButtonItem = buttonsItem;
  }

  [self loadPageAtIndex:0];
}

- (void)viewDidLayoutSubviews;
{
  [self layoutScrollViewAndPages];
}

- (void)changePage:(UISegmentedControl *)buttons;
{
  if (buttons.selectedSegmentIndex == 0) {
    [self loadPreviousPage];
  } else {
    [self loadNextPage];
  }
}

#pragma mark - Page loading related methods

- (FTWebPageView *)previousPageView;
{
  return self.pageViews[0];
}

- (FTWebPageView *)currentPageView;
{
  return self.pageViews[1];
}

- (FTWebPageView *)nextPageView;
{
  return self.pageViews[2];
}

- (void)layoutScrollViewAndPages;
{
  CGSize size = self.pagingScrollView.frame.size;
  size.width *= self.numberOfPages;
  self.pagingScrollView.contentSize = size;
  [self updateFrameOfPageView:self.previousPageView forPageIndex:self.currentPageIndex-1];
  [self updateFrameOfPageView:self.currentPageView  forPageIndex:self.currentPageIndex];
  [self updateFrameOfPageView:self.nextPageView     forPageIndex:self.currentPageIndex+1];

}

- (void)updateFrameOfPageView:(FTWebPageView *)pageView forPageIndex:(NSInteger)index;
{
  pageView.pageIndex = index;
  if (index >= 0 && index < self.numberOfPages) {
    CGRect frame = self.pagingScrollView.frame;
    frame.origin.x = (frame.size.width * index) + (self.pageMargin / 2);
    frame.origin.y = 0;
    frame.size.width -= self.pageMargin;
    pageView.frame = frame;
    [self.pagingScrollView addSubview:pageView];
  } else {
    [pageView removeFromSuperview];
  }
}

- (void)_loadPageAtIndex:(NSInteger)index;
{
  if (index < 0 || index >= self.numberOfPages) {
    return;
  }

  NSInteger before = self.currentPageIndex;
  self.currentPageIndex = index;

  if (self.currentPageIndex == before + 1) {
    // advance one page, so move old `previous' webview to the back to be the new `next' webview
    FTWebPageView *pageView = self.pageViews[0];
    [self.pageViews addObject:pageView];
    [self.pageViews removeObjectAtIndex:0];
    [self loadPageAtIndex:self.currentPageIndex+1 inPageView:self.nextPageView];

  } else if (self.currentPageIndex == before - 1) {
    // go back one page, so move old `next' webview to the front to be the new `previous' webview
    FTWebPageView *pageView = self.pageViews[2];
    [self.pageViews insertObject:pageView atIndex:0];
    [self.pageViews removeObjectAtIndex:3];
    [self loadPageAtIndex:self.currentPageIndex-1 inPageView:self.previousPageView];

  } else {
    // load all webviews
    [self loadPageAtIndex:self.currentPageIndex-1 inPageView:self.previousPageView];
    [self loadPageAtIndex:self.currentPageIndex   inPageView:self.currentPageView];
    [self loadPageAtIndex:self.currentPageIndex+1 inPageView:self.nextPageView];
  }

  [self layoutScrollViewAndPages];

  self.pageControl.currentPage = index;

  if (self.hasPageNavigationButtons) {
    [self.navigationButtons setEnabled:!self.isAtFirstPage forSegmentAtIndex:0];
    [self.navigationButtons setEnabled:!self.isAtLastPage  forSegmentAtIndex:1];
  }
}

- (void)loadPageAtIndex:(NSInteger)index inPageView:(FTWebPageView *)pageView;
{
  if (index >= 0 && index < self.numberOfPages) {
    pageView.URL = self.URLs[index];
  }
}

#pragma mark - FTWebPageView delegate methods

- (void)pageViewDidFinishLoad:(FTWebPageView *)pageView;
{
  if (!self.didNotifyDelegateThatFirstPageIsLoaded && self.currentPageView == pageView) {
    self.notifiedDelegateThatFirstPageIsLoaded = YES;
    if ([self.delegate respondsToSelector:@selector(webViewControllerDidLoadFirstPage:)]) {
      [self.delegate webViewControllerDidLoadFirstPage:self];
    }
  }
}

- (void)webPageView:(FTWebPageView *)webPageView
   didReceiveAction:(NSString *)actionName
      withArguments:(NSDictionary *)arguments;
{
  if ([self.delegate respondsToSelector:@selector(webViewController:didReceiveAction:withArguments:)]) {
    [self.delegate webViewController:self didReceiveAction:actionName withArguments:arguments];
  }
}

#pragma mark - pagingScrollView delegate methods

- (void)assignHTMLElementClass:(NSString *)className toPageView:(FTWebPageView *)pageView;
{
  if ([self.delegate respondsToSelector:@selector(webViewController:willChangeClassOfPageView:toClass:)]) {
    className = [self.delegate webViewController:self willChangeClassOfPageView:pageView toClass:className];
  }
  pageView.HTMLElementClass = className;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
  [self assignHTMLElementClass:@"swiping" toPageView:self.previousPageView];
  [self assignHTMLElementClass:@"swiping visible" toPageView:self.currentPageView];
  [self assignHTMLElementClass:@"swiping" toPageView:self.nextPageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
  if (self.isRotating) return;

  CGFloat pageWidth = self.pagingScrollView.frame.size.width;
  CGFloat pageX = pageWidth * self.currentPageIndex;
  CGFloat nextPageThreshold = pageX + (pageWidth / 2);
  CGFloat previousPageThreshold = pageX - (pageWidth / 2);

  if (self.pagingScrollView.contentOffset.x > nextPageThreshold) {
    [self _loadPageAtIndex:self.currentPageIndex+1];
  } else if (self.pagingScrollView.contentOffset.x < previousPageThreshold) {
    [self _loadPageAtIndex:self.currentPageIndex-1];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)willDecelerate;
{
  if (!willDecelerate) {
    [self scrollingHorizontallyDidEnd];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
  [self scrollingHorizontallyDidEnd];
}

- (void)scrollingHorizontallyDidEnd;
{
  [self.previousPageView scrollToTop];
  [self.nextPageView scrollToTop];

  [self assignHTMLElementClass:@"" toPageView:self.previousPageView];
  [self assignHTMLElementClass:@"visible" toPageView:self.currentPageView];
  [self assignHTMLElementClass:@"" toPageView:self.nextPageView];
}

#pragma mark - handle rotation events

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
  if (self.presentingViewController) {
    return [self.presentingViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
  }
  return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

// During rotation the scrollViewDidScroll: messages should be ignored.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration;
{
  self.rotating = YES;
}

// Update the layout as it should be at the end of the rotation animation.
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration;
{
  [self layoutScrollViewAndPages];
  CGPoint offset = self.pagingScrollView.contentOffset;
  offset.x = self.pagingScrollView.frame.size.width * self.currentPageIndex;
  self.pagingScrollView.contentOffset = offset;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  self.rotating = NO;
}

@end
