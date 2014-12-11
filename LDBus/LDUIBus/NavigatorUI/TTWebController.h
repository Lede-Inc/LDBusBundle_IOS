//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


// UI
#import <UIKit/UIKit.h>

@protocol TTWebControllerDelegate;

@interface TTWebController : UIViewController <UIWebViewDelegate> {
@protected
  UIWebView*        _webView;
  UIView*           _headerView;
  NSURL*            _loadingURL;
}

/**
 * The current web view URL. If the web view is currently loading a URL, then the loading URL is
 * returned instead.
 */
@property (nonatomic, readonly) NSURL*  URL;

/**
 * A view that is inserted at the top of the web view, within the scroller.
 */
@property (nonatomic, retain)   UIView* headerView;

/**
 * The web controller delegate
 */
@property (nonatomic, assign)   id<TTWebControllerDelegate> delegate;

/**
 * Navigate to the given URL.
 */
- (void)openURL:(NSURL*)URL;

/**
 * Load the given request using UIWebView's loadRequest:.
 *
 * @param request  A URL request identifying the location of the content to load.
 */
- (void)openRequest:(NSURLRequest*)request;

@end
