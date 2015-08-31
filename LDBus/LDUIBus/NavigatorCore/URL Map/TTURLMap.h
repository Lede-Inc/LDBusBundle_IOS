//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TTNavigationMode.h"

@class TTURLNavigatorPattern;

@interface TTURLMap : NSObject {
    NSMutableDictionary *_objectMappings;  //存储通过URL初始化的Object
    NSMutableArray *_objectPatterns;       //存储URLPattern
    NSMutableArray *_fragmentPatterns;     //存储带fragement的URLPattern
    NSMutableDictionary *_schemes;         //存储支持的scheme

    //当找不到匹配时的URLPattern，一般配置一个WebViewController
    TTURLNavigatorPattern *_defaultObjectPattern;
    BOOL _invalidPatterns;  //是否有不合法的Pattern
}


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
- (void)from:(NSString *)URL
    toViewController:(id)target
      navigationMode:(TTNavigationMode)mode
          withWebURL:(NSString *)webURL;
- (void)from:(NSString *)URL
              parent:(NSString *)parentURL
    toViewController:(id)target
      navigationMode:(TTNavigationMode)mode
          withWebURL:(NSString *)webURL;


/**
 * Gets or creates the object with a pattern that matches the URL.
 *
 * Object mappings are checked first, and if no object is bound to the URL then pattern
 * matching is used to create a new object.
 */
- (id)objectForURL:(NSString *)URL
             query:(NSDictionary *)query
           pattern:(TTURLNavigatorPattern **)pattern;
- (id)dispatchURL:(NSString *)URL toTarget:(id)target query:(NSDictionary *)query;


/**
 * 根据url获取匹配的pattern
 */
- (TTURLNavigatorPattern *)matchObjectPattern:(NSURL *)URL;
- (TTURLNavigatorPattern *)defaultObjectPattern;

@end
