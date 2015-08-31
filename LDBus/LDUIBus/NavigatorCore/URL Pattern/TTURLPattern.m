//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "TTURLPattern.h"

// UINavigator (Private)
#import "TTURLWildcard.h"
#import "TTURLLiteral.h"

// Core
#import "TTUtil.h"
#import "NSStringAdditions.h"
#import <objc/runtime.h>


@implementation TTURLPattern
@synthesize URL = _URL;
@synthesize webURL = _webURL;
@synthesize scheme = _scheme;
@synthesize specificity = _specificity;
@synthesize selector = _selector;


- (id)init
{
    self = [super init];
    if (self) {
        _path = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)dealloc
{
    TT_RELEASE_SAFELY(_URL);
    TT_RELEASE_SAFELY(_webURL);
    TT_RELEASE_SAFELY(_scheme);
    TT_RELEASE_SAFELY(_path);
    TT_RELEASE_SAFELY(_query);
    TT_RELEASE_SAFELY(_fragment);

    [super dealloc];
}


#pragma mark -
#pragma mark Private
/**
 * 解析每一个path、query、fragement选项
 * 将urlpattern中的selector选项解析为TTURLWildcard
 * 将普通的选项解析为TTURLLiteral，只用做区分url
 */
- (id<TTURLPatternText>)parseText:(NSString *)text
{
    NSInteger len = text.length;
    if (len >= 2 && [text characterAtIndex:0] == '(' && [text characterAtIndex:len - 1] == ')') {
        NSInteger endRange = len > 3 && [text characterAtIndex:len - 2] == ':' ? len - 3 : len - 2;

        NSString *name = len > 2 ? [text substringWithRange:NSMakeRange(1, endRange)] : nil;

        TTURLWildcard *wildcard = [[[TTURLWildcard alloc] init] autorelease];
        wildcard.name = name;

        ++_specificity;
        return wildcard;
    } else {
        TTURLLiteral *literal = [[[TTURLLiteral alloc] init] autorelease];
        literal.name = text;
        _specificity += 2;
        return literal;
    }
}


/**
 * 解析path选项
 */
- (void)parsePathComponent:(NSString *)value
{
    id<TTURLPatternText> component = [self parseText:value];
    [_path addObject:component];
}


/**
 * 解析query选项
 */
- (void)parseParameter:(NSString *)name value:(NSString *)value
{
    if (nil == _query) {
        _query = [[NSMutableDictionary alloc] init];
    }

    id<TTURLPatternText> component = [self parseText:value];
    [_query setObject:component forKey:name];
}


#pragma mark -
#pragma mark Public
- (Class)classForInvocation
{
    return nil;
}


/**
 * 设置制定的selector
 * 需要制定的targetclass能够响应selector
 */
- (void)setSelectorIfPossible:(SEL)selector
{
    Class cls = [self classForInvocation];
    if (nil == cls || class_respondsToSelector(cls, selector) ||
        class_getClassMethod(cls, selector)) {
        _selector = selector;
    }
}

/**
 * 根据解析的selector选项拼接为selector
 */
- (void)setSelectorWithNames:(NSArray *)names
{
    NSString *selectorName = [[names componentsJoinedByString:@":"] stringByAppendingString:@":"];
    SEL selector = NSSelectorFromString(selectorName);
    [self setSelectorIfPossible:selector];
}


/**
 * 解析URL pattern
 */
- (void)compileURL
{
    NSURL *URL = [NSURL URLWithString:_URL];
    _scheme = [URL.scheme copy];
    //解析host和path，host作为path的第一个选项
    if (URL.host) {
        [self parsePathComponent:URL.host];

        if (URL.path) {
            for (NSString *name in URL.path.pathComponents) {
                if (![name isEqualToString:@"/"]) {
                    [self parsePathComponent:name];
                }
            }
        }
    }

    //解析query
    if (URL.query) {
        _qKeys = [URL.query queryKeysSortByFIFO:NSUTF8StringEncoding];
        NSDictionary *query = [URL.query queryContentsUsingEncoding:NSUTF8StringEncoding];
        for (NSString *name in _qKeys) {
            NSString *value = [[query objectForKey:name] objectAtIndex:0];
            [self parseParameter:name value:value];
        }
    }

    //解析fragement
    if (URL.fragment) {
        _fragment = [[self parseText:URL.fragment] retain];
    }
}


@end
