//
//  LDMRoutes.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/25/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMRoutes.h"
#import "LDMBusWebControllerProtocol.h"
#import "LDMContainer.h"
#import "TTURLAction.h"
#import "TTNavigationMode.h"
#import "LDMNavigator.h"
#import "LDMNavigatorInternal.h"

@interface _LDMRoute : NSObject {
    
}

@property (nonatomic, strong) NSString *pattern; //匹配Pattern
@property (nonatomic, assign) NSUInteger priority; //pattern的处理优先级
@property (nonatomic, strong) NSString *webHandlerClassString;
@property (nonatomic, strong) NSArray *patternPathComponents;
@property (nonatomic, assign) BOOL isModal;

- (BOOL)isParametersMatchForURL:(NSURL *)URL components:(NSArray *)URLComponents;

@end


@implementation _LDMRoute

- (BOOL)isParametersMatchForURL:(NSURL *)URL components:(NSArray *)URLComponents {
    BOOL isParameterMatch = NO;
    
    if (!self.patternPathComponents) {
        self.patternPathComponents = [[self.pattern pathComponents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    }
    
    // do a quick component count check to quickly eliminate incorrect patterns
    BOOL componentCountEqual = self.patternPathComponents.count == URLComponents.count;
    BOOL routeContainsWildcard = !NSEqualRanges([self.pattern rangeOfString:@"*"], NSMakeRange(NSNotFound, 0));
    if (componentCountEqual || routeContainsWildcard) {
        // now that we've identified a possible match, move component by component to check if it's a match
        NSUInteger componentIndex = 0;
        isParameterMatch = YES;
        
        for (NSString *patternComponent in self.patternPathComponents) {
            NSString *URLComponent = nil;
            if (componentIndex < [URLComponents count]) {
                URLComponent = URLComponents[componentIndex];
            } else if ([patternComponent isEqualToString:@"*"]) { // match /foo by /foo/*
                URLComponent = [URLComponents lastObject];
            }
            
            if ([patternComponent hasPrefix:@":"]) {
                //nothing to do
            } else if ([patternComponent isEqualToString:@"*"]) {
                // match wildcards
                isParameterMatch = YES;
                break;
            } else if (![patternComponent isEqualToString:URLComponent]) {
                // a non-variable component did not match, so this route doesn't match up - on to the next one
                isParameterMatch = NO;
                break;
            }
            componentIndex++;
        }
    }
    
    return isParameterMatch;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"JLRoute %@ (%@)", self.pattern, @(self.priority)];
}

@end






/**
 * 管理scheme选项
 *
 */
@interface LDMRoutes() {
    
}
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, strong) NSString *namespaceKey;

@end

@implementation LDMRoutes
@synthesize routes = _routes;
@synthesize namespaceKey = _namespaceKey;

+ (instancetype)routesForScheme:(NSString *)scheme {
    LDMRoutes *routesController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeControllersMap = [[NSMutableDictionary alloc] initWithCapacity:2];
    });
    
    if (!routeControllersMap[scheme]) {
        routesController = [[LDMRoutes alloc] init];
        routesController.namespaceKey = scheme;
        routeControllersMap[scheme] = routesController;
    }
    
    routesController = routeControllersMap[scheme];
    
    return routesController;
}


- (void)addRoute:(NSString *)routePattern webHandler:(NSString *)webControllerClassString isModal:(BOOL)isModal{
    [self addRoute:routePattern priority:0 webHandler:webControllerClassString isModal:isModal];
}



-(void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority webHandler:(NSString *)webControllerClassString isModal:(BOOL) isModal {
    Class webCtrlClass = NSClassFromString(webControllerClassString);
    //如果指定webcontroller不存在，或者 指定webController不遵守指定协议
    if(!webCtrlClass || ![webCtrlClass conformsToProtocol:@protocol(LDMBusWebControllerProtocol)]){
#ifdef DEBUG
        NSAssert(NO, @"the specified web controller is not exist in bundle or not conform to LDMBusWebControllerProtocol, please check!!!");
#endif
    }
    
    else {
        _LDMRoute *route = [[_LDMRoute alloc] init];
        route.pattern = routePattern;
        route.priority = priority;
        route.webHandlerClassString = webControllerClassString;
        route.isModal = isModal;
        
        //如果是最低优先级，插入到数组后方
        if(priority == 0){
            if(_routes == nil){
                _routes = [[NSMutableArray alloc] initWithCapacity:2];
            }
            
            [_routes addObject:route];
        }
        
        //否则从前往后查找到第一个优先级低的pattern，插入到该pattern之前
        else {
            NSArray *existingRoutes = self.routes;
            NSUInteger index = 0;
            for (_LDMRoute *existingRoute in existingRoutes) {
                if (existingRoute.priority < priority) {
                    [self.routes insertObject:route atIndex:index];
                    break;
                }
                index++;
            }//for
        }//else
        
    }
}


+(BOOL) canRouteURL:(NSURL *)URL {
    if (!URL) {
        return NO;
    }

    // figure out which routes controller to use based on the scheme
    //如果没有当前scheme的处理器，返回NO
    LDMRoutes *routesController = routeControllersMap[[URL scheme]];
    if(routesController == nil){
        return NO;
    }
    
    return [self routeURL:URL withController:routesController executeBlock:NO];
}


-(BOOL)canRouteURL:(NSURL *)URL {
    return [[self class] routeURL:URL withController:self executeBlock:NO];
}


+ (BOOL)routeURL:(NSURL *)URL {
    if (!URL) {
        return NO;
    }
    
    LDMRoutes *routesController = routeControllersMap[[URL scheme]];
    if(routesController == nil){
        return NO;
    }
  
    return [self routeURL:URL withController:routesController executeBlock:YES];
}


- (BOOL)routeURL:(NSURL *)URL{
    return [[self class] routeURL:URL withController:self executeBlock:YES];
}



+ (BOOL)routeURL:(NSURL *)URL withController:(LDMRoutes *)routesController executeBlock:(BOOL)executeBlock {
    BOOL didRoute = NO;
    NSArray *routes = routesController.routes;
    // break the URL down into path components and filter out any leading/trailing slashes from it
    NSArray *pathComponents = [(URL.pathComponents ?: @[]) filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    
    if ([URL.host rangeOfString:@"."].location == NSNotFound) {
        // For backward compatibility, handle scheme://path/to/ressource as if path was part of the
        // path if it doesn't look like a domain name (no dot in it)
        pathComponents = [@[URL.host] arrayByAddingObjectsFromArray:pathComponents];
    }
    
    
    for (_LDMRoute *route in routes) {
        BOOL isMatch = [route isParametersMatchForURL:URL components:pathComponents];
        if (isMatch) {
            if (!executeBlock) {
                return YES;
            }

            id webControllerHandler = [[[NSClassFromString(route.webHandlerClassString) class] alloc] init];
            if(webControllerHandler && [webControllerHandler isKindOfClass:[UIViewController class]]){
                LDMNavigator *_navigator = [[LDMContainer container] getMainNavigator];
                [_navigator presentDependantController:webControllerHandler
                                      parentController:_navigator.topViewController
                                                  mode:(route.isModal ? TTNavigationModeModal : TTNavigationModeCreate)
                                                action:[TTURLAction actionWithURLPath:nil]];
                
                //打开网络连接
                didRoute = [webControllerHandler handleURLFromUIBus:URL];
            }
            
            
            if (didRoute) {
                break;
            }
        }
    }
    
    return didRoute;
}




@end






