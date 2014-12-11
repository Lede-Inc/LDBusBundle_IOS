//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "UIViewController+TTNavigator.h"

// UINavigator
#import "TTBaseNavigator.h"

// UICommon
#import "UIViewControllerAdditions.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTDebug.h"
#import "TTDebugFlags.h"

static NSMutableDictionary* gNavigatorURLs          = nil;

static NSMutableSet*        gsNavigatorControllers  = nil;
static NSTimer*             gsGarbageCollectorTimer = nil;

static const NSTimeInterval kGarbageCollectionInterval = 20;


/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIViewController_TTNavigator)


@implementation UIViewController (TTNavigator)

/**
 * 参加导航的ViewController，最后将初始化放到这个
 */
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
    }
    
    return self;
}


#pragma mark -
#pragma mark Garbage Collection
/**
 * 导航的ViewController的垃圾容器
 */
+ (NSMutableSet*)ttNavigatorControllers {
    if (nil == gsNavigatorControllers) {
        gsNavigatorControllers = [[NSMutableSet alloc] init];
    }
    return gsNavigatorControllers;
}


/**
 * 执行垃圾回收
 */
+ (void)doNavigatorGarbageCollection {
    //调用ViewControllerAddtion unsetNavigatorProperties执行回收
    NSMutableSet* controllers = [UIViewController ttNavigatorControllers];
    [self doGarbageCollectionWithSelector: @selector(unsetNavigatorProperties)
                            controllerSet: controllers];
    
    //清空之后销毁垃圾容器,最后是通过清空navigationController来回收内存
    if ([controllers count] == 0) {
        TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                        @"Killing the navigator garbage collector.");
        [gsGarbageCollectorTimer invalidate];
        TT_RELEASE_SAFELY(gsGarbageCollectorTimer);
        TT_RELEASE_SAFELY(gsNavigatorControllers);
    }
}



/**
 * 当通过URL生成一个ViewController之后，将改viewController放到垃圾回收箱中
 */
+ (void)ttAddNavigatorController:(UIViewController*)controller {
    //所有的viewController通过进行垃圾回收
    [[UIViewController ttNavigatorControllers] addObject:controller];
    
    //每20S通过UIViewController Class执行一次垃圾回收
    if (nil == gsGarbageCollectorTimer) {
        gsGarbageCollectorTimer =
        [[NSTimer scheduledTimerWithTimeInterval: kGarbageCollectionInterval
                                          target: [UIViewController class]
                                        selector: @selector(doNavigatorGarbageCollection)
                                        userInfo: nil
                                         repeats: YES] retain];
    }
}


#pragma mark -
#pragma mark Public
- (NSString*)navigatorURL {
    return self.originalNavigatorURL;
}


- (NSString*)originalNavigatorURL {
    NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
    return [gNavigatorURLs objectForKey:key];
}


/**
 * 保存每个ViewController的OriginalURL
 * 通过gNavigatorURLs map对象进行添加和移除
 */
- (void)setOriginalNavigatorURL:(NSString*)URL {
    NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
    if (nil != URL) {
        if (nil == gNavigatorURLs) {
            gNavigatorURLs = [[NSMutableDictionary alloc] init];
        }
        [gNavigatorURLs setObject:URL forKey:key];
        
        [UIViewController ttAddNavigatorController:self];
    } else {
        [gNavigatorURLs removeObjectForKey:key];
    }
}

- (void)unsetNavigatorProperties {
    TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Unsetting this controller's properties: %X", (unsigned int)self);
    
    NSString* urlPath = self.originalNavigatorURL;
    if (nil != urlPath) {
        TTDCONDITIONLOG(TTDFLAG_CONTROLLERGARBAGECOLLECTION,
                        @"Removing this URL path: %@", urlPath);
        self.originalNavigatorURL = nil;
    }
}


@end