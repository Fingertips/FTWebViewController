# FTWebViewController

A iOS UIWebView controller that provides pagination for multiple HTML documents
and a simple way to trigger controller actions from these documents.

This has been extracted from two in-production applications.

### Usage

Initialize an instance with the `-[FTWebViewController initWithPageURLs:]`
method, passing it a list of URLs, one for each page.

In order to handle actions triggered from the documents, initialize an instance
with `-[FTWebViewController initWithPageURLs:applicationScheme:]`, passing it a
identifier by which your custom actions will be recognized, and implement the
relevant `FTWebViewControllerDelegate` method.

For instance, with an application scheme of `BananaRecipes`, the following link:

```
<a href="BananaRecipes://AddToFavorites/?id=42">Add to favorites.</a>
```

Will trigger a call to your delegate with the following parameters:

```objc
- (void)webViewController:(FTWebViewController *)webViewController
           receivedAction:(NSString *)actionName
            withArguments:(NSDictionary *)arguments;
{
  NSLog(@"Action name: %@", actionName); // => AddToFavorites
  NSLog(@"Arguments: %@", arguments);    // => { id = 42; }
}
```

### License

This code is available under the MIT license. See the LICENSE file for details.