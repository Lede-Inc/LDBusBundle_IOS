//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TTNavigationMode.h"

@class TTURLNavigatorPattern;

@interface TTURLMap : NSObject {
    NSMutableDictionary*    _objectMappings; //存储通过URL初始化的Object
    NSMutableArray*         _objectPatterns; //存储URLPattern
    NSMutableArray*         _fragmentPatterns; //存储带fragement的URLPattern
    NSMutableDictionary*    _schemes;  //存储支持的scheme
    
    TTURLNavigatorPattern*  _defaultObjectPattern; //当找不到匹配时的URLPattern，一般配置一个WebViewController
    BOOL                    _invalidPatterns; //是否有不合法的Pattern
}

/**
 * Adds a URL pattern which will perform a selector on an object when loaded.
 * 在一个已初始化的Object中打开一个ViewController
 */
- (void)from:(NSString*)URL toObject:(id)object withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toObject:(id)object selector:(SEL)selector withWebURL:(NSString *)webURL;

/**
 * Adds a URL pattern which will create and present a view controller when loaded.
 *
 * The selector will be called on the view controller after is created, and arguments from
 * the URL will be extracted using the pattern and passed to the selector.
 *
 * target can be either a Class which is a subclass of UIViewController, or an object which
 * implements a method that returns a UIViewController instance.  If you use an object, the
 * selector will be called with arguments extracted from the URL, and the view controller that
 * you return will be the one that is presented.
 */
- (void)from:(NSString*)URL toViewController:(id)target withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toViewController:(id)target transition:(NSInteger)transition withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition withWebURL:(NSString *)webURL;

/**
 * Adds a URL pattern which will create and present a share view controller when loaded.
 *
 * Controllers created with the "share" mode, meaning that it will be created once and re-used
 * until it is destroyed.
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL;

/**
 * Adds a URL pattern which will create and present a modal view controller when loaded.
 */
- (void)from:(NSString*)URL toModalViewController:(id)target withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toModalViewController:(id)target transition:(NSInteger)transition withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toModalViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition withWebURL:(NSString *)webURL;

- (void)from:(NSString*)URL toPopoverViewController:(id)target withWebURL:(NSString *)webURL;
- (void)from:(NSString*)URL toPopoverViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL;


/**
 * Removes all objects and patterns mapped to a URL.
 */
- (void)removeURL:(NSString*)URL;


/**
 * Removes objects bound literally to the URL.
 */
- (void)removeObjectForURL:(NSString*)URL;

/**
 * Removes all bound objects;
 */
- (void)removeAllObjects;

/**
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object mappings are checked first, and if no object is bound to the URL then pattern
 * matching is used to create a new object.
 */
- (id)objectForURL:(NSString*)URL;
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query;
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query
      pattern:(TTURLNavigatorPattern**)pattern;

- (id)dispatchURL:(NSString*)URL toTarget:(id)target query:(NSDictionary*)query;

/**
 * Tests if there is a pattern that matches the URL and if so returns its navigation mode.
 */
- (TTNavigationMode)navigationModeForURL:(NSString*)URL;

/**
 * Tests if there is a pattern that matches the URL and if so returns its transition.
 */
- (NSInteger)transitionForURL:(NSString*)URL;

/**
 * Returns YES if there is a registered pattern with the URL scheme.
 */
- (BOOL)isSchemeSupported:(NSString*)scheme;

/**
 * Returns YES if the URL is destined for an external app.
 */
- (BOOL)isAppURL:(NSURL*)URL;


/**
 * 根据url获取匹配的pattern
 */
- (TTURLNavigatorPattern*)matchObjectPattern:(NSURL*)URL;
-(TTURLNavigatorPattern *)defaultObjectPattern;

@end
