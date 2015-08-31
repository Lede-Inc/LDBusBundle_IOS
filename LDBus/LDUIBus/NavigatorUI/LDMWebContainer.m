//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMWebContainer.h"
#import "TTUtil.h"


@implementation LDMWebContainer


#pragma mark -
#pragma mark - initial method

/**
 * 通过URL调用和初始化
 */
- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        //判定是否重新传递URL，优先级在前面
        NSString *ttdefault_url = [query objectForKey:TTDEGRADE_URL];
        if (ttdefault_url != nil) {
            [self openURL:[NSURL URLWithString:ttdefault_url]];
        }
    }
    return self;
}

- (void)openURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [self openRequest:request];
}

- (void)openRequest:(NSURLRequest *)request
{
    [self view];
    [_webView loadRequest:request];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }

    return self;
}


- (void)loadView
{
    [super loadView];
    _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _webView.backgroundColor = [UIColor yellowColor];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _webView.delegate = nil;
    _webView = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.view.window makeKeyWindow];
    [super viewWillDisappear:animated];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
@end
