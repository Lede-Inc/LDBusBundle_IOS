//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


// UI
#import <UIKit/UIKit.h>
#import "LDMWebContainerProtocol.h"


@interface LDMWebContainer : UIViewController <UIWebViewDelegate, LDMWebContainerProtocol> {
@protected
    UIWebView*        _webView;
}

/**
 * 打开URL
 */
- (void)openURL:(NSURL*)URL;


@end
