//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "TTURLNavigatorPattern.h"

// UINavigator (private)
#import "UIViewController+LDMNavigator.h"
#import "TTURLWildcard.h"
#import "TTURLArguments.h"

// Core
#import "TTUtil.h"
#import "TTDebug.h"
#import "NSStringAdditions.h"


#import <objc/runtime.h>

static NSString* kUniversalURLPattern = @"*";
@implementation TTURLNavigatorPattern
@synthesize targetClass     = _targetClass;
@synthesize targetObject    = _targetObject;
@synthesize navigationMode  = _navigationMode;
@synthesize parentURL       = _parentURL;
@synthesize transition      = _transition;
@synthesize argumentCount   = _argumentCount;

#pragma mark - initial method
/**
 * 初始化
 */
- (id)initWithTarget: (id)target
                mode: (TTNavigationMode)navigationMode {
    self = [super init];
    if (self) {
        _navigationMode = navigationMode;
        
        if ([target class] == target && navigationMode) {
            _targetClass = target;
            
        } else {
            _targetObject = target;
        }
    }
    
    return self;
}


- (id)initWithTarget:(id)target {
    self = [self initWithTarget:target mode:TTNavigationModeNone];
    if (self) {
    }
    return self;
}


- (id)init {
    self = [self initWithTarget:nil];
    if (self) {
    }
    
    return self;
}


- (void)dealloc {
    TT_RELEASE_SAFELY(_parentURL);
    [super dealloc];
}


- (NSString *)description {
    if (nil != _targetClass) {
        return [NSString stringWithFormat:@"%@ => %@", _URL, _targetClass];
    } else {
        return [NSString stringWithFormat:@"%@ => %@", _URL, _targetObject];
    }
}



#pragma mark -
#pragma mark Private
/**
 * 判断当前是否有初始化的class
 * targetClass存在且配置了导航方式
 */
- (BOOL)instantiatesClass {
    return nil != _targetClass && TTNavigationModeNone != _navigationMode;
}


/**
 * 判断是否可以获得targetClass的method
 */
- (BOOL)callsInstanceMethod {
  return (nil != _targetObject && [_targetObject class] != _targetObject)
         || nil != _targetClass;
}



/**
 * 通过pattern中的parse选项的个数来第一步判断pattern是否相同
 */
- (NSComparisonResult)compareSpecificity:(TTURLPattern*)pattern2 {
    if (_specificity > pattern2.specificity) {
        return NSOrderedAscending;
        
    } else if (_specificity < pattern2.specificity) {
        return NSOrderedDescending;
        
    } else {
        return NSOrderedSame;
    }
}


/**
 * 根据配置选项创建一个初始化Selector
 * 将urlpattern parse的所有selector选项组装成一个selector
 * 如果class没有实现selector，则配置默认的initWithNavigationURL:query selector
 * 如果连默认的都没有实现，selector配置为nil， 初始化的时候调用alloc init完成初始化
 */
- (void)deduceSelector {
    //获取selector选项
    NSMutableArray* parts = [NSMutableArray array];
    for (id<TTURLPatternText> pattern in _path) {
        if ([pattern isKindOfClass:[TTURLWildcard class]]) {
            TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
            if (wildcard.name) {
                [parts addObject:wildcard.name];
            }
        }
    }
    
    for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
        if ([pattern isKindOfClass:[TTURLWildcard class]]) {
            TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
            if (wildcard.name) {
                [parts addObject:wildcard.name];
            }
        }
    }
    
    if ([_fragment isKindOfClass:[TTURLWildcard class]]) {
        TTURLWildcard* wildcard = (TTURLWildcard*)_fragment;
        if (wildcard.name) {
            [parts addObject:wildcard.name];
        }
    }
    
    //组装selector选项设置，系统会在selector不存在的时候加query参数
    if (parts.count) {
        [self setSelectorWithNames:parts];
        if (!_selector) {
            [parts addObject:@"query"];
            [self setSelectorWithNames:parts];
        }
        
    }
    
    //如果没有实现，设置默认的初始化selector
    else {
        [self setSelectorIfPossible:@selector(initWithNavigatorURL:query:)];
    }
    
    //如果没有指定selector或者也没有实现Bus要求的Selector
    if(!_selector){
        [self setSelectorIfPossible:@selector(initWithNibName:bundle:)];
    }
}




/**
 * 分析selector的参数个数和参数类型
 */
- (void)analyzeMethod {
    Class cls = [self classForInvocation];
    Method method = [self callsInstanceMethod]? class_getInstanceMethod(cls, _selector): class_getClassMethod(cls, _selector);
    if (method) {
        _argumentCount = method_getNumberOfArguments(method)-2;
        // Look up the index and type of each argument in the method
        const char* selName = sel_getName(_selector);
        NSString* selectorName = [[NSString alloc] initWithBytesNoCopy:(char*)selName
                                                                length:strlen(selName)
                                                              encoding:NSASCIIStringEncoding freeWhenDone:NO];
        NSArray* argNames = [selectorName componentsSeparatedByString:@":"];
        
        //逐步分析path、query、fragement的selector选项的参数类型
        for (id<TTURLPatternText> pattern in _path) {
            [self analyzeArgument:pattern method:method argNames:argNames];
        }
        
        for (id<TTURLPatternText> pattern in [_query objectEnumerator]) {
            [self analyzeArgument:pattern method:method argNames:argNames];
        }
        
        if (_fragment) {
            [self analyzeArgument:_fragment method:method argNames:argNames];
        }
        
        [selectorName release];
    }
}



/**
 * 分析每个selector选项的参数
 */
- (void)analyzeArgument: (id<TTURLPatternText>)pattern
                 method: (Method)method
               argNames: (NSArray*)argNames {
    if ([pattern isKindOfClass:[TTURLWildcard class]]) {
        TTURLWildcard* wildcard = (TTURLWildcard*)pattern;
        //参数的index
        wildcard.argIndex = [argNames indexOfObject:wildcard.name];
        if (wildcard.argIndex == NSNotFound) {
            TTDINFO(@"Argument %@ not found in @selector(%s)", wildcard.name, sel_getName(_selector));
        } else {
            //设置参数的类型
            char argType[256];
            method_getArgumentType(method, (unsigned int)wildcard.argIndex+2, argType, 256);
            wildcard.argType = TTConvertArgumentType(argType[0]);
        }
    }
}




/**
 * 将URL传入的参数值设置给Pattern selector对应的参数
 */
- (BOOL)setArgument: (NSString*)text
            pattern: (id<TTURLPatternText>)patternText
      forInvocation: (NSInvocation*)invocation {
    if ([patternText isKindOfClass:[TTURLWildcard class]]) {
        TTURLWildcard* wildcard = (TTURLWildcard*)patternText;
        NSInteger argIndex = wildcard.argIndex;
        if (argIndex != NSNotFound && argIndex < _argumentCount) {
            switch (wildcard.argType) {
                case TTURLArgumentTypeNone: {
                    break;
                }
                case TTURLArgumentTypeInteger: {
                    int val = [text intValue];
                    [invocation setArgument:&val atIndex:argIndex+2];
                    break;
                }
                case TTURLArgumentTypeLongLong: {
                    long long val = [text longLongValue];
                    [invocation setArgument:&val atIndex:argIndex+2];
                    break;
                }
                case TTURLArgumentTypeFloat: {
                    float val = [text floatValue];
                    [invocation setArgument:&val atIndex:argIndex+2];
                    break;
                }
                case TTURLArgumentTypeDouble: {
                    double val = [text doubleValue];
                    [invocation setArgument:&val atIndex:argIndex+2];
                    break;
                }
                case TTURLArgumentTypeBool: {
                    BOOL val = [text boolValue];
                    [invocation setArgument:&val atIndex:argIndex+2];
                    break;
                }
                default: {
                    [invocation setArgument:&text atIndex:argIndex+2];
                    break;
                }
            }
            return YES;
        }
    }
    return NO;
}


/**
 * 当通过调用url初始化object的时候，
 * 解析调用URL，给invocation设置初始化参数
 */
- (void)setArgumentsFromURL: (NSURL*)URL
              forInvocation: (NSInvocation*)invocation
                      query: (NSDictionary*)query {
    NSInteger remainingArgs = _argumentCount;
    NSMutableDictionary* unmatchedArgs = query ? [[query mutableCopy] autorelease] : nil;
    
    //遍历path
    NSArray* pathComponents = URL.path.pathComponents;
    for (NSInteger i = 0; i < _path.count; ++i) {
        id<TTURLPatternText> patternText = [_path objectAtIndex:i];
        NSString* text = i == 0 ? URL.host : [pathComponents objectAtIndex:i];
        if ([self setArgument:text pattern:patternText forInvocation:invocation]) {
            --remainingArgs;
        }
    }
    
    //遍历query，将pattern中没有的query选项放到unmatchedArgs map
    NSDictionary* URLQuery = [URL.query queryContentsUsingEncoding:NSUTF8StringEncoding];
    if (URLQuery.count) {
        for (NSString* name in [URLQuery keyEnumerator]) {
            id<TTURLPatternText> patternText = [_query objectForKey:name];
            NSString* text = [[URLQuery objectForKey:name] objectAtIndex:0];
            if (patternText) {
                if ([self setArgument:text pattern:patternText forInvocation:invocation]) {
                    --remainingArgs;
                }
                
            } else {
                if (!unmatchedArgs) {
                    unmatchedArgs = [NSMutableDictionary dictionary];
                }
                [unmatchedArgs setObject:text forKey:name];
            }
        }
    }
    
    //如果参数没有初始化完成，将query传入的参数设置到query
    if (remainingArgs && unmatchedArgs.count) {
        // If there are unmatched arguments, and the method signature has extra arguments,
        // then pass the dictionary of unmatched arguments as the last argument
        [invocation setArgument:&unmatchedArgs atIndex:_argumentCount+1];
    }
    
    //遍历fragement
    if (URL.fragment && _fragment) {
        [self setArgument:URL.fragment pattern:_fragment forInvocation:invocation];
    }
}


#pragma mark - Public
#pragma mark TTURLPattern
- (Class)classForInvocation {
    return _targetClass ? _targetClass : [_targetObject class];
}


- (BOOL)isUniversal {
    return [_URL isEqualToString:kUniversalURLPattern];
}


- (BOOL)isFragment {
    return [_URL rangeOfString:@"#" options:NSBackwardsSearch].location != NSNotFound;
}


/**
 * 解析参数
 */
- (void)compile {
    if ([_URL isEqualToString:kUniversalURLPattern]) {
        if (!_selector) {
            [self deduceSelector];
        }
        
    } else {
        [self compileURL];
        if (!_selector) {
            [self deduceSelector];
        }
        if (_selector) {
            [self analyzeMethod];
        }
    }
}


/**
 * 判断当前pattern是否匹配调用URL
 * 只匹配url的path和fragement部分
 */
- (BOOL)matchURL:(NSURL*)URL {
    //由于传进来的scheme可能是多个，所以不匹配scheme
    if (!URL.scheme || !URL.host /*|| ![_scheme isEqualToString:URL.scheme]*/) {
        return NO;
    }
    
    NSArray* pathComponents = URL.path.pathComponents;
    NSInteger componentCount = URL.path.length ? pathComponents.count : (URL.host ? 1 : 0);
    if (componentCount != _path.count) {
        return NO;
    }
    
    if (_path.count && URL.host) {
        id<TTURLPatternText>hostPattern = [_path objectAtIndex:0];
        if (![hostPattern match:URL.host]) {
            return NO;
        }
    }
    
    for (NSInteger i = 1; i < _path.count; ++i) {
        id<TTURLPatternText>pathPattern = [_path objectAtIndex:i];
        NSString* pathText = [pathComponents objectAtIndex:i];
        if (![pathPattern match:pathText]) {
            return NO;
        }
    }
    
    if ((URL.fragment && !_fragment) || (_fragment && !URL.fragment)) {
        return NO;
    } else if (URL.fragment && _fragment && ![_fragment match:URL.fragment]) {
        return NO;
    }
    return YES;
}


/*
 * 通过url生成object，直接通过object invoke一个object
 */
- (id)invoke: (id)target withURL: (NSURL*)URL query: (NSDictionary*)query {
    id returnValue = nil;
    NSMethodSignature *sig = [target methodSignatureForSelector:self.selector];
    if (sig) {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:target];
        [invocation setSelector:self.selector];
        //默认的pattern
        if (self.isUniversal) {
            [invocation setArgument:&URL atIndex:2];
            if (query) {
                [invocation setArgument:&query atIndex:3];
            }
            
        } else {
            [self setArgumentsFromURL:URL forInvocation:invocation query:query];
        }
        [invocation invoke];
        
        if (sig.methodReturnLength) {
            [invocation getReturnValue:&returnValue];
        }
    }
    
    return returnValue;
}



/**
 * 通过target class alloc init 或者调用selector初始化一个object
 * @return the newly created object or nil if something went wrong
 */
- (id)createObjectFromURL: (NSURL*)URL query: (NSDictionary*)query {
    id returnValue = nil;
    if (self.instantiatesClass) {
        //suppress static analyzer warning for this part
        // - invoke:withURL:query actually calls an - init method
        // which returns either a new object with retain count of +1
        // or returnValue (which already has +1 retain count)
#ifndef __clang_analyzer__
        returnValue = [_targetClass alloc];
        if (_selector) {
            returnValue = [self invoke:returnValue withURL:URL query:query];
            
        } else {
            returnValue = [returnValue init];
        }
        [returnValue autorelease];
#endif
        
    } else {
        id target = [_targetObject retain];
        if (_selector) {
            returnValue = [self invoke:target withURL:URL query:query];
            
        } else {
            TTDWARNING(@"No object created from URL:'%@'", URL);
        }
        [target release];
    }
    return returnValue;
}


@end
