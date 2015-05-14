//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLAction.h"
#import "TTUtil.h"
#import "TTDebug.h"


@implementation TTURLAction
@synthesize urlPath       = _urlPath;
@synthesize parentURLPath = _parentURLPath;
@synthesize query         = _query;
@synthesize animated      = _animated;
@synthesize sourceRect    = _sourceRect;
@synthesize sourceView    = _sourceView;
@synthesize sourceButton  = _sourceButton;
@synthesize sourceViewController = _sourceViewController;
@synthesize transition    = _transition;
@synthesize isDirectDeal = _isDirectDeal;


#pragma mark - 
#pragma mark - initial method

+ (id)actionWithURLPath:(NSString*)urlPath {
    return [[[self alloc] initWithURLPath:urlPath] autorelease];
}


- (id)initWithURLPath:(NSString*)urlPath {
    self = [super init];
    if (self) {
        self.urlPath = urlPath;
        self.animated = YES;
        self.transition = UIViewAnimationTransitionNone;
        self.isDirectDeal = YES;
    }
    
    return self;
}


- (id)init {
    NSAssert(0, @"TTAction must init with urlPath");
    return nil;
}


- (void)dealloc {
    TT_RELEASE_SAFELY(_urlPath);
    TT_RELEASE_SAFELY(_parentURLPath);
    TT_RELEASE_SAFELY(_query);
    TT_RELEASE_SAFELY(_sourceView);
    TT_RELEASE_SAFELY(_sourceButton);
    TT_RELEASE_SAFELY(_sourceViewController);
    
    [super dealloc];
}


#pragma mark -
#pragma mark - property assgin

- (TTURLAction*)applyParentURLPath:(NSString*)parentURLPath {
    self.parentURLPath = parentURLPath;
    return self;
}


- (TTURLAction*)applyQuery:(NSDictionary*)query {
    self.query = query;
    return self;
}


- (TTURLAction*)applyAnimated:(BOOL)animated {
    self.animated = animated;
    return self;
}


- (TTURLAction*)applyIfNeedPresent:(BOOL)ifNeedPresent{
    self.isDirectDeal = ifNeedPresent;
    return self;
}


- (TTURLAction*)applySourceRect:(CGRect)sourceRect {
    self.sourceRect = sourceRect;
    return self;
}


- (TTURLAction*)applySourceView:(UIView*)sourceView {
    self.sourceView = sourceView;
    return self;
}


- (TTURLAction*)applySourceButton:(UIBarButtonItem*)sourceButton {
    self.sourceButton = sourceButton;
    return self;
}


- (TTURLAction*)applySourceViewController:(UIViewController*)sourceViewController{
    self.sourceViewController = sourceViewController;
    return self;
}


- (TTURLAction*)applyTransition:(UIViewAnimationTransition)transition {
    self.transition = transition;
    return self;
}
@end
