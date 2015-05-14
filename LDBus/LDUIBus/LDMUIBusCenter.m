//
//  LDMUIBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDMUIBusCenter.h"

#import "LDMBusContext.h"
#import "LDMBundle.h"
#import "LDMContainer.h"
#import "LDMUIBusConnector.h"
#import "LDMRoutes.h"

#import "TTURLAction.h"
#import "TTURLActionResponse.h"
#import "TTDebug.h"

#define TITLE_MESSAGEACTION @"uibus_messageaction"
#define TITLE_MESSAGERESULT @"uibus_messageresult"

static LDMUIBusCenter *uibusCenter = nil;
@interface LDMUIBusCenter () {
    NSMutableArray *_UIBusMessageQueue;
}
@end

@implementation LDMUIBusCenter


+(LDMUIBusCenter *)uibusCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uibusCenter = [[self alloc] init];
    });
    return uibusCenter;
}


-(id)init {
    self = [super init];
    if(self){
        _UIBusMessageQueue = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}


/**
 * 向UIBus请求当前是否能够处理该URL
 */
+(BOOL)canOpenURL:(NSString *)url{
    BOOL success = NO;
    //询问webScheme能否处理
    if([LDMRoutes canRouteURL:[NSURL URLWithString:url]]){
        success = YES;
    }
    
    //如果LDMRoutes不能处理，询问Bus总线能否处理
    if(!success){
        LDMUIBusCenter *center = [LDMUIBusCenter uibusCenter];
        success = [center canOpenURLWithBus:url];
    }
    
    return success;
}


+(BOOL)sendUIMessage:(TTURLAction *)action{
    BOOL success = NO;
    NSURL *handleURL = [NSURL URLWithString:action.urlPath];
    
    //首先交给webScheme LDMRoutes去处理
    if([LDMRoutes canRouteURL:handleURL]){
        success = [LDMRoutes routeURL:handleURL];
    }
    
    //如果LDMRoutes不能处理或者处理未成功，由Bus总线去处理
    if(!success){
        LDMUIBusCenter *center = [LDMUIBusCenter uibusCenter];
        if([center getMessageFromConnetor:action]){
            //转发消息并调用响应connetor 生成viewControll
            success = [center forwardMessageToOtherBundles];
            
            //不管成功与否，立即重置消息队列
            [center updateMessageQueue];
        }
    }
    
    return success;
}


+(UIViewController*)receiveURLCtrlFromUIBus:(TTURLAction *)action{
    TTURLActionResponse *response = [LDMUIBusCenter handleURLActionRequest:action];
    UIViewController *ctrl = nil;
    if(response && response.viewController != nil){
        ctrl = response.viewController;
    }
    return ctrl;
}


+(TTURLActionResponse *)handleURLActionRequest:(TTURLAction *)action {
    if(action.isDirectDeal) return nil;
    
    TTURLActionResponse *response = nil;
    LDMUIBusCenter *center = [LDMUIBusCenter uibusCenter];
    if([center getMessageFromConnetor:action]){
        //转发消息并调用响应connetor 生成viewControll
        BOOL success = [center forwardMessageToOtherBundles];
        if(success){
            response = [center getURLActionResponse];
        }
        
        //不管成功与否，立即重置消息队列
        [center updateMessageQueue];
    }
    
    return response;

}


/**
 * 清空消息队列
 */
-(void) updateMessageQueue {
    if(_UIBusMessageQueue.count > 0){
        [_UIBusMessageQueue removeLastObject];
    }
}

/**
 * 获取messageQueue的响应ViewController
 */
-(TTURLActionResponse *) getURLActionResponse {
    TTURLActionResponse *response = nil;
    if(_UIBusMessageQueue.count > 0){
        response = [[_UIBusMessageQueue lastObject] objectForKey:TITLE_MESSAGERESULT];
        if(![response.viewController isKindOfClass:[UIViewController class]]){
            response =  nil;
        }
    }
    
    return response;
}


/**
 * 调用UIbus总线的封装方法，统一将所有参数封装到TTURLAction
 * 从connetor参数封装成Action，存到当前容量为1的messageCache中；
 */
-(BOOL) getMessageFromConnetor:(TTURLAction *) action {
    //存储当前处理的action
    [_UIBusMessageQueue addObject:@{TITLE_MESSAGEACTION:action}];
    return YES;
}


/**
 * 向其他所有接入总线的bundle转发消息
 */
-(BOOL) forwardMessageToOtherBundles {
    // 向总的buscenter获取Bundle列表
    NSMutableDictionary *bundlesMap = [LDMContainer container].bundlesMap;
    if(!bundlesMap || bundlesMap.allKeys.count<=0 ){
        TTDPRINT(@"LDUIBusCenter>> bundle list is empty>>");
        return NO;
    }
    
    //遍历bundles map，处理消息
    BOOL success = NO;
    BOOL isAllCheck = NO;
    @try {
        TTURLAction *action = [[_UIBusMessageQueue lastObject] objectForKey:TITLE_MESSAGEACTION];
        NSArray *keys = bundlesMap.allKeys;
        int i = 0;
        for(; i < keys.count; i++){
            NSString *bundleKey = [keys objectAtIndex:i];
            LDMBundle *bundle = [bundlesMap objectForKey:bundleKey];
            //如果当前bundle可以处理该url
            if([bundle.uibusConnetor canOpenInBundle:action.urlPath]){
                @synchronized(_UIBusMessageQueue){
                    //如果是url跳转，直接调用响应的connector处理
                    if(action.isDirectDeal){
                        success = [bundle.uibusConnetor dealWithURLMessageFromBus:action];
                    }
                    
                    //如果只是url实例化，则调用connetor返回
                    else {
                        TTURLActionResponse *response = [bundle.uibusConnetor handleURLActionRequest:action];
                        if(response.viewController){
                            success = YES;
                            //存储结果
                            [_UIBusMessageQueue replaceObjectAtIndex:_UIBusMessageQueue.count-1 withObject:@{TITLE_MESSAGEACTION:action, TITLE_MESSAGERESULT:response}];
                        }
                    }
                }
                break;
            }
            
        }
        
        isAllCheck = (i == keys.count)?YES:NO;
    }
    @catch (NSException *exception) {
        TTDPRINT(@"LDUIBusCenter>> try via connetor create viewCtrl error>>");
    }
    @finally {
        //处理遍历所有bundle的map无法找到匹配url的情况
        if(isAllCheck){
            TTDPRINT(@"LDUIBusCenter>> all bundles have no matched pattern>>");
        }
    }
    
    if(success){
        TTDPRINT(@"LDUIBusCenter>> excute action success");
    }

    return success;
}


/**
 * 向总线询问是否能够处理某个URL
 */
-(BOOL)canOpenURLWithBus:(NSString *)url {
    // 向总的buscenter获取Bundle列表
    NSMutableDictionary *bundlesMap = [LDMContainer container].bundlesMap;
    if(!bundlesMap || bundlesMap.allKeys.count<=0 ){
        TTDPRINT(@"LDUIBusCenter>> bundle list is empty>>");
        return NO;
    }
    
    BOOL isCan = NO;
    NSArray *keys = bundlesMap.allKeys;
    for(int i=0; i < keys.count; i++){
        NSString *bundleKey = [keys objectAtIndex:i];
        LDMBundle *bundle = [bundlesMap objectForKey:bundleKey];
        //如果当前bundle可以处理该url
        if([bundle.uibusConnetor canOpenInBundle:url]){
            isCan = YES;
            break;
        }
    }
    
    return isCan;
}




@end


@implementation LDMBusContext (LDMUIBusCenter)

+(void)registerSpecialScheme:(NSString *)scheme
                   addRoutes:(NSString *)routePattern
            handleController:(NSString *)handleControllerClassString{
    [[self class] registerSpecialScheme:scheme addRoutes:routePattern handleController:handleControllerClassString isModal:YES];
}


+(void)registerSpecialScheme:(NSString *)scheme
                   addRoutes:(NSString *)routePattern
            handleController:(NSString *)handleControllerClassString
                     isModal:(BOOL)isModal{
    if(scheme && ![scheme isEqualToString:@""] &&
       routePattern && ![routePattern isEqualToString:@""] &&
       handleControllerClassString && ![handleControllerClassString isEqualToString:@""]){
        [[LDMRoutes routesForScheme:scheme] addRoute:routePattern webHandler:handleControllerClassString isModal:isModal];
    }

    
}

@end

