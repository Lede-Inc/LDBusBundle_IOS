//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLMap.h"

// UINavigator
#import "TTURLNavigatorPattern.h"
// UINavigator (private)
#import "UIViewController+LDMNavigator.h"

// Core
#import "TTGlobalCore.h"
#import "TTCorePreprocessorMacros.h"
#import <objc/runtime.h>


@implementation TTURLMap

- (void)dealloc {
    TT_RELEASE_SAFELY(_objectMappings);
    TT_RELEASE_SAFELY(_objectPatterns);
    TT_RELEASE_SAFELY(_fragmentPatterns);
    TT_RELEASE_SAFELY(_schemes);
    TT_RELEASE_SAFELY(_defaultObjectPattern);
    [super dealloc];
}


#pragma mark -
#pragma mark Private
/**
 * What's a scheme?
 * It's a specific URL that is registered with the URL map.
 * Example:
 *  @"tt://some/path"
 *
 * This method registers them.
 *
 * @private
 */
- (void)registerScheme:(NSString*)scheme {
    if (nil != scheme) {
        if (nil == _schemes) {
            _schemes = [[NSMutableDictionary alloc] init];
        }
        [_schemes setObject:[NSNull null] forKey:scheme];
    }
}


/**
 * 解析URL携带的Pattern信息到Pattern对象中
 */
- (void)addObjectPattern: (TTURLNavigatorPattern*)pattern
                  forURL: (NSString*)URL {
    pattern.URL = URL;
    [pattern compile];
    [self registerScheme:pattern.scheme];
    
    //存储默认打开Pattern
    if (pattern.isUniversal) {
        [_defaultObjectPattern release];
        _defaultObjectPattern = [pattern retain];
        
    }
    
    //如果带有fragement，保存到_fragePattern数组中
    else if (pattern.isFragment) {
        if (!_fragmentPatterns) {
            _fragmentPatterns = [[NSMutableArray alloc] init];
        }
        [_fragmentPatterns addObject:pattern];
        
    }
    
    //如果不带fragement，标记为invalid,存储到objectPatterns数组中
    else {
        _invalidPatterns = YES;
        
        if (!_objectPatterns) {
            _objectPatterns = [[NSMutableArray alloc] init];
        }
        
        [_objectPatterns addObject:pattern];
    }
}


/**
 * 检查当前的URLMap中是否有根调用URL匹配的Pattern
 * 如果有，返回； 如果没有，返回默认Pattern
 */
- (TTURLNavigatorPattern*)matchObjectPattern:(NSURL*)URL {
    //将pattern进行排序
    if (_invalidPatterns) {
        [_objectPatterns sortUsingSelector:@selector(compareSpecificity:)];
        _invalidPatterns = NO;
    }
    
    for (TTURLNavigatorPattern* pattern in _objectPatterns) {
        if ([pattern matchURL:URL]) {
            return pattern;
        }
    }
    
    return _defaultObjectPattern;
}



/**
 * 判断当前URL是否是一个WebURL
 * @private
 */
- (BOOL)isWebURL:(NSURL*)URL {
    return [URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"ftp"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"ftps"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"data"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"file"] == NSOrderedSame;
}



/**
 * 判断当前URL是否是调用apple本身提供的服务
 */
- (BOOL)isExternalURL:(NSURL*)URL {
    if ([URL.host isEqualToString:@"maps.google.com"]
        || [URL.host isEqualToString:@"itunes.apple.com"]
        || [URL.host isEqualToString:@"phobos.apple.com"]) {
        return YES;
        
    } else {
        return NO;
    }
}



#pragma mark -
#pragma mark Mapping
/**
 * 给已经存在的Object添加URL，直接返回Object，不用初始化过程
 * 暂时用不上，因为主要是通过配置完成跳转，但是可以提供给bundle内部进行调用
 */
- (void)from:(NSString*)URL toObject:(id)target withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target];
    pattern.webURL = webURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}



/**
 * 给URL配置一个selector，当调用URL的时候，在当前target，调用selector，返回一个ViewController
 */
- (void)from:(NSString*)URL toObject:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target];
    pattern.webURL = webURL;
    pattern.selector = selector;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个create方式的ViewController Pattern
 */
- (void)from:(NSString*)URL toViewController:(id)target withWebURL:(NSString *)webURL{
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeCreate];
    pattern.webURL = webURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个create方式的ViewController Pattern
 * 配置一个默认初始化的Selector
 */
- (void)from:(NSString*)URL toViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeCreate];
    pattern.webURL = webURL;
    pattern.selector = selector;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


- (void)from:(NSString*)URL toViewController:(id)target transition:(NSInteger)transition withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeCreate];
    pattern.webURL = webURL;
    pattern.transition = transition;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个create方式的ViewController Pattern
 * 配置在parentURL处打开当前ViewController
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeCreate];
    pattern.webURL = webURL;
    pattern.parentURL = parentURL;
    pattern.selector = selector;
    pattern.transition = transition;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}



/**
 * 配置一个share方式的ViewController Pattern
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeShare];
    pattern.webURL = webURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个share方式的ViewController Pattern
 * 配置一个默认打开的Selector
 */
- (void)from:(NSString*)URL toSharedViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeShare];
    pattern.webURL = webURL;
    pattern.selector = selector;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个share方式的ViewController Pattern
 * 配置在parentURL处打开
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeShare];
    pattern.webURL = webURL;
    pattern.parentURL = parentURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toSharedViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeShare];
    pattern.webURL = webURL;
    pattern.parentURL = parentURL;
    pattern.selector = selector;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个Modal方式的ViewController Pattern
 */
- (void)from:(NSString*)URL toModalViewController:(id)target withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeModal];
    pattern.webURL = webURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


- (void)from:(NSString*)URL toModalViewController:(id)target selector:(SEL)selector  withWebURL:(NSString *)webURL{
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeModal];
    pattern.webURL = webURL;
    pattern.selector = selector;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


- (void)from:(NSString*)URL toModalViewController:(id)target transition:(NSInteger)transition withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeModal];
    pattern.webURL = webURL;
    pattern.transition = transition;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}



- (void)from:(NSString*)URL parent:(NSString*)parentURL
        toModalViewController:(id)target selector:(SEL)selector transition:(NSInteger)transition withWebURL:(NSString *)webURL{
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:TTNavigationModeModal];
    pattern.webURL = webURL;
    pattern.parentURL = parentURL;
    pattern.selector = selector;
    pattern.transition = transition;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个popover方式的ViewController Pattern
 */
- (void)from:(NSString*)URL toPopoverViewController:(id)target withWebURL:(NSString *)webURL{
    TTURLNavigatorPattern* pattern =
    [[TTURLNavigatorPattern alloc] initWithTarget: target
                                             mode: TTNavigationModePopover];
    pattern.webURL = webURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}

- (void)from:(NSString*)URL toPopoverViewController:(id)target selector:(SEL)selector withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern =
    [[TTURLNavigatorPattern alloc] initWithTarget:target
                                             mode:TTNavigationModePopover];
    pattern.webURL = webURL;
    pattern.selector = selector;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}




#pragma mark -
#pragma mark Public
/**
 * 将通过URLPattern生成的Object放到_objectMap中
 */
- (void)setObject:(id)object forURL:(NSString*)URL {
    if (nil == _objectMappings) {
        _objectMappings = TTCreateNonRetainingDictionary();
    }
    [_objectMappings setObject:object forKey:URL];
    
    //如果初始化的ViewController，将其放到垃圾回收中
    if ([object isKindOfClass:[UIViewController class]]) {
        [UIViewController ttAddNavigatorController:object];
    }
}


/**
 * 删除URL对应的Pattern
 * 先删除声称的Object，再删除Pattern
 */
- (void)removeURL:(NSString*)URL {
    [_objectMappings removeObjectForKey:URL];
    
    for (TTURLNavigatorPattern* pattern in _objectPatterns) {
        if ([URL isEqualToString:pattern.URL]) {
            [_objectPatterns removeObject:pattern];
            break;
        }
    }
}


/**
 * 删除url对应生成的Object
 */
- (void)removeObjectForURL:(NSString*)URL {
    [_objectMappings removeObjectForKey:URL];
}


/**
 * 删除所有生成的Object
 */
- (void)removeAllObjects {
    TT_RELEASE_SAFELY(_objectMappings);
}



/**
 * 根据URL get或者create Object
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForURL:(NSString*)URL {
    return [self objectForURL:URL query:nil pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForURL:(NSString*)URL query:(NSDictionary*)query {
    return [self objectForURL:URL query:query pattern:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForURL: (NSString*)URL
             query: (NSDictionary*)query
           pattern: (TTURLNavigatorPattern**)outPattern {
    id object = nil;
    //如果object存在，直接返回，不用每次都创建
    if (_objectMappings) {
        object = [_objectMappings objectForKey:URL];
        if (object) {
            return object;
        }
    }
    
    NSURL* theURL = [NSURL URLWithString:URL];
    TTURLNavigatorPattern* pattern  = [self matchObjectPattern:theURL];
    if (pattern) {
        //判断pattern中的class或者object是否存在, 不存在用webview打开
        NSMutableDictionary *mutquery = nil;
        if(pattern.targetClass == nil && pattern.targetObject == nil){
            //读取pattern中的参数组装webview的url
            NSURL *patternWebURL = [NSURL URLWithString:pattern.webURL];
            NSString *actQuery = theURL.query == nil ? @"": [NSString stringWithFormat:@"?%@", theURL.query];
            NSString *actFragement = theURL.fragment == nil ? @"":[NSString stringWithFormat:@"#%@", theURL.fragment];
            NSString *actWebURL = [NSString stringWithFormat:@"%@://%@%@%@%@", patternWebURL.scheme, patternWebURL.host, patternWebURL.path, actQuery, actFragement];
            
            //放置到query对象中
            if(query){
               mutquery = [NSMutableDictionary dictionaryWithDictionary:query];
            } else {
                mutquery = [[[NSMutableDictionary alloc] initWithCapacity:1] autorelease];
            }
            if(![mutquery objectForKey:@"_ttdefault_url_"] && pattern.webURL){
                NSLog(@"actWebURL>>>>%@", actWebURL);
                [mutquery setObject:actWebURL  forKey:@"_ttdefault_url_"];
            }
            pattern = _defaultObjectPattern;
        }
        
        if (!object) {
            object = [pattern createObjectFromURL:theURL query:mutquery?mutquery:query];
            
        }
        
        if (pattern.navigationMode == TTNavigationModeShare && object) {
            [self setObject:object forURL:URL];
        }
        
        if (outPattern) {
            *outPattern = pattern;
        }
        
        return object;
        
    } else {
        return nil;
    }
}


/**
 * 对带有fragement的url直接通过invoke声称一个ViewController
 * 要求target是一个object，而不是一个class
 */
- (id)dispatchURL:(NSString*)URL toTarget:(id)target query:(NSDictionary*)query {
    NSURL* theURL = [NSURL URLWithString:URL];
    for (TTURLNavigatorPattern* pattern in _fragmentPatterns) {
        if ([pattern matchURL:theURL]) {
            return [pattern invoke:target withURL:theURL query:query];
        }
    }
    
    // If there is no match, check if the fragment points to a method on the target
    if (theURL.fragment) {
        SEL selector = NSSelectorFromString(theURL.fragment);
        if (selector && [target respondsToSelector:selector]) {
            [target performSelector:selector];
        }
    }
    
    return nil;
}



/**
 * 获取url的present方式
 */
- (TTNavigationMode)navigationModeForURL:(NSString*)URL {
    NSURL* theURL = [NSURL URLWithString:URL];
    if (![self isAppURL:theURL]) {
        TTURLNavigatorPattern* pattern = [self matchObjectPattern:theURL];
        if (pattern) {
            return pattern.navigationMode;
        }
    }
    return TTNavigationModeExternal;
}


/**
 * 获取url的动画
 */
- (NSInteger)transitionForURL:(NSString*)URL {
    TTURLNavigatorPattern* pattern = [self matchObjectPattern:[NSURL URLWithString:URL]];
    return pattern.transition;
}



/**
 * 判断当前map 是否支持scheme
 */
- (BOOL)isSchemeSupported:(NSString*)scheme {
    return nil != scheme && !![_schemes objectForKey:scheme];
}



/**
 * 判断URL是不是一个APP外部打开的URL
 */
- (BOOL)isAppURL:(NSURL*)URL {
    return [self isExternalURL:URL]
          || ([[UIApplication sharedApplication] canOpenURL:URL]
              && ![self isSchemeSupported:URL.scheme]
              && ![self isWebURL:URL]);
}

@end
