//
//  LDUIBusConnector.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/6/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDUIBusConnector.h"

#import "LDUIBusCenter.h"
#import "LDBusContext.h"

#import "LDNavigator.h"
#import "TTURLMap.h"
#import "TTURLAction.h"
#import "TTURLNavigatorPattern.h"
#import "UIViewController+LDNavigator.h"
#import "UIViewControllerAdditions.h"

@interface LDUIBusConnector() {
    TTURLMap *_bundleMap;
    LDNavigator *_navigator;
}

@end

@implementation LDUIBusConnector

-(void)setBundleURLMap:(TTURLMap *)map {
    _bundleMap = map;
}

-(void) setGlobalNavigator:(LDNavigator*) navigator{
    _navigator = navigator;
}


#pragma mark - require
//接收URLMessage并处理：via Action
-(BOOL) dealWithURLMessageFromBus:(TTURLAction *)action {
    UIViewController *controller = [self viewControllerForAction:action];
    if (controller==nil) {
        return NO;
    }
    
    BOOL success = NO;
    if ([self presentViewController:controller
                   parentController:nil]) {
        success = YES;
    } else {
        TTURLNavigatorPattern *pattern = [_bundleMap matchObjectPattern:[NSURL URLWithString:action.urlPath]];
        action.transition = action.transition ? action.transition : pattern.transition;
        [_navigator presentController: controller
                                parentURLPath: action.parentURLPath
                                  withPattern: pattern
                                       action: action];
        success = YES;
    }
    
    return success;
}


/**
 * 根据指定Pattern生成ViewController
 */
- (UIViewController*)viewControllerForURL: (NSString*)URL
                                    query: (NSDictionary*)query
                                  pattern: (TTURLPattern**)pattern {
    NSRange fragmentRange = [URL rangeOfString:@"#" options:NSBackwardsSearch];
    if (fragmentRange.location != NSNotFound) {
        //如果带有fragement，先截取baseURL
        NSString* baseURL = [URL substringToIndex:fragmentRange.location];
        //如果当前navigator的topViewController是baseURL
        if ([_navigator.URL isEqualToString:baseURL]) {
            UIViewController* controller = _navigator.visibleViewController;
            id result = [_bundleMap dispatchURL:URL toTarget:controller query:query];
            if ([result isKindOfClass:[UIViewController class]]) {
                return result;
            } else {
                return controller;
            }
            
        }
        
        //否则，通过BaseURL生成一个ViewController
        //如果该URL能够处理，那么BaseURL一定是在该bundleMap下
        else {
            id object = [_bundleMap objectForURL:baseURL query:nil pattern:(TTURLNavigatorPattern**)pattern];
            if (object) {
                id result = [_bundleMap dispatchURL:URL toTarget:object query:query];
                if ([result isKindOfClass:[UIViewController class]]) {
                    return result;
                    
                } else {
                    return object;
                }
                
            } else {
                return nil;
            }
        }
    }
    
    id object = [_bundleMap objectForURL:URL query:query pattern:(TTURLNavigatorPattern**)pattern];
    if (object) {
        UIViewController* controller = object;
        controller.originalNavigatorURL = URL;
        return controller;
    } else {
        return nil;
    }
}

@end



/**
 * 完成UIConnetor的调用
 */
@implementation LDBusContext (LDUIBusConnector)
/**
 * 向当前bundle的connector 发送action消息
 */
+(BOOL)sendURLWithAction:(TTURLAction *)action{
    action.animated = YES;
    return [LDUIBusCenter sendUIMessage:action];
}

/**
 * 向当前bundle的Connetor 发送URL消息
 */
+(BOOL)sendURL:(NSString *)url{
    TTURLAction *action = [TTURLAction actionWithURLPath:url];
    action.animated = YES;
    return [LDUIBusCenter sendUIMessage:action];;
}

/**
 * 向当前bundle的connector 发送url和query组装消息
 */
+(BOOL)sendURL:(NSString *)url query:(NSDictionary *)query{
    TTURLAction *action = [TTURLAction actionWithURLPath:url];
    action.query = query;
    action.animated = YES;
    return [LDUIBusCenter sendUIMessage:action];

}

/**
 * 向当前bundle的connetor 申请某个url对应的ctrl；
 */
+(UIViewController *)controllerForURL:(NSString *)url{
    TTURLAction *action = [TTURLAction actionWithURLPath:url];
    action.ifNeedPresent = NO;
    return [LDUIBusCenter receiveURLCtrlFromUIBus:action];
}

@end


@implementation LDUIBusConnector(ToBeOverwrite)

/**
 * 接收消息，查看消息是否能够处理
 * 调用TTURLMap 的urlmatch，如果返回pattern不是默认pattern，则可以处理；
 */
-(BOOL) canOpenInBundle:(NSString *)url{
    BOOL isCan = NO;
    TTURLNavigatorPattern *pattern = [_bundleMap matchObjectPattern:[NSURL URLWithString:url]];
    if(!pattern.isUniversal){
        isCan = YES;
    }
    return isCan;
}


//根据URLAction生成ViewController
- (UIViewController*)viewControllerForAction:(TTURLAction *)action{
    if (nil == action || nil == action.urlPath) {
        return nil;
    }
    
    // We may need to modify the urlPath, so let's create a local copy.
    NSString* urlPath = action.urlPath;
    
    TTURLNavigatorPattern* pattern = nil;
    UIViewController* controller = [self viewControllerForURL: urlPath
                                                        query: action.query
                                                      pattern: &pattern];
    return controller;
}

- (BOOL)presentViewController:(UIViewController*)controller
             parentController:(UIViewController*)parentController {
    return NO;
}

@end
