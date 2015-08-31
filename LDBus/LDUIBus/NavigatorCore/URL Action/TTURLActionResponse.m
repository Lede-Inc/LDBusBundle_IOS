//
//  TTURLActionResponse.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/24/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "TTURLActionResponse.h"
#import "TTUtil.h"

@implementation TTURLActionResponse
@synthesize viewController = _viewController;
@synthesize navigatorPattern = _navigatorPattern;
@synthesize bundleName = _bundleName;


- (id)init
{
    NSAssert(0, @"TTURLActionResponse must init with viewcontroller and pattern and bundleName");
    return nil;
}


- (id)initWithViewController:(UIViewController *)theViewController
                     pattern:(TTURLNavigatorPattern *)theNavigatorPattern
                sourceBundle:(NSString *)theBundleName
{
    self = [super init];
    if (self) {
        self.viewController = theViewController;
        self.navigatorPattern = theNavigatorPattern;
        self.bundleName = theBundleName;
    }
    return self;
}


- (void)dealloc
{
    TT_RELEASE_SAFELY(_viewController);
    TT_RELEASE_SAFELY(_navigatorPattern);
    TT_RELEASE_SAFELY(_bundleName);

    [super dealloc];
}

@end
