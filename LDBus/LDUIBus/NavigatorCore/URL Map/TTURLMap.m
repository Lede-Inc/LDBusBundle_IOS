//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLMap.h"

// UINavigator
#import "TTURLNavigatorPattern.h"
#import "UIViewController+LDMNavigator.h"

// Core
#import "TTUtil.h"
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
 * This method registers them.
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
 * 去掉scheme的URL, 由于当前匹配scheme不进行匹配，
 */
-(NSString *)urlWithoutScheme:(NSString *)urlString{
    NSURL *URL = [NSURL URLWithString:urlString];
    NSString *scheme = URL.scheme;
    NSString *urlNoScheme = [urlString substringFromIndex:scheme.length+3];
    return urlNoScheme;
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
 * 将通过URLPattern生成的Object放到_objectMap中
 */
- (void)setObject:(id)object forURL:(NSString*)URL {
    if (nil == _objectMappings) {
        _objectMappings = TTCreateNonRetainingDictionary();
    }
    
    //通过scheme存储ViewController
    [_objectMappings setObject:object forKey:[self urlWithoutScheme:URL]];
    
    //如果初始化的ViewController，将其放到垃圾回收中
    if ([object isKindOfClass:[UIViewController class]]) {
        [UIViewController ttAddNavigatorController:object];
    }
}



#pragma mark -
#pragma mark Mapping
/**
 * 配置一个mode方式的ViewController Pattern
 */
- (void)from:(NSString*)URL toViewController:(id)target navigationMode:(TTNavigationMode)mode withWebURL:(NSString *)webURL{
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:mode];
    pattern.webURL = webURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


/**
 * 配置一个mode方式的ViewController Pattern
 * 配置在parentURL处打开当前ViewController
 */
- (void)from:(NSString*)URL parent:(NSString*)parentURL toViewController:(id)target navigationMode:(TTNavigationMode)mode withWebURL:(NSString *)webURL {
    TTURLNavigatorPattern* pattern = [[TTURLNavigatorPattern alloc] initWithTarget:target
                                                                              mode:mode];
    pattern.webURL = webURL;
    pattern.parentURL = parentURL;
    [self addObjectPattern:pattern forURL:URL];
    [pattern release];
}


#pragma mark -
#pragma mark Public

/**
 * 根据URL get或者create Object
 */
- (id)objectForURL: (NSString*)URL
             query: (NSDictionary*)query
           pattern: (TTURLNavigatorPattern**)outPattern {
    id object = nil;
    //如果object存在，直接返回，不用每次都创建
    if (_objectMappings) {
        object = [_objectMappings objectForKey:[self urlWithoutScheme:URL]];
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
            if(![mutquery objectForKey:@"_ttdegrade_url_"] && pattern.webURL){
                NSLog(@"actWebURL>>>>%@", actWebURL);
                [mutquery setObject:actWebURL  forKey:@"_ttdegrade_url_"];
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
 * 检查当前的URLMap中是否有跟调用URL匹配的Pattern
 * 如果有，返回； 如果没有，返回默认Pattern
 */
- (TTURLNavigatorPattern*)matchObjectPattern:(NSURL*)URL {
    //将pattern根据url长度（path数＋query数）进行排序
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


-(TTURLNavigatorPattern *)defaultObjectPattern{
    return _defaultObjectPattern;
}

@end
