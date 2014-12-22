//
//  LDMUIBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDMUIBusCenter.h"

#import "LDMBundle.h"
#import "LDMContainer.h"
#import "LDMUIBusConnector.h"

#import "TTURLAction.h"
#import "TTWebController.h"

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


+(BOOL)sendUIMessage:(TTURLAction *)action{
    BOOL success = NO;
    
    //是否是打开其他APP的url
    NSURL* theURL = [NSURL URLWithString:action.urlPath];
    if ([[UIApplication sharedApplication] canOpenURL:theURL]) {
        [[UIApplication sharedApplication] openURL:theURL];
        return YES;
    }
    
    
    LDMUIBusCenter *center = [LDMUIBusCenter uibusCenter];
    if([center getMessageFromConnetor:action]){
        //转发消息并调用响应connetor 生成viewControll
        success = [center forwardMessageToOtherBundles];
        
        //不管成功与否，立即重置消息队列
        [center updateMessageQueue];
    }
    
    return success;
}

+(UIViewController*)receiveURLCtrlFromUIBus:(TTURLAction *)action{
    if(action.ifNeedPresent) return nil;
    
    UIViewController *ctrl = nil;
    LDMUIBusCenter *center = [LDMUIBusCenter uibusCenter];
    if([center getMessageFromConnetor:action]){
        //转发消息并调用响应connetor 生成viewControll
        BOOL success = [center forwardMessageToOtherBundles];
        if(success){
            ctrl = [center getResponseViewCtrl];
        }
        
        //不管成功与否，立即重置消息队列
        [center updateMessageQueue];
    }
    
    return ctrl;
}

-(id)init {
    self = [super init];
    if(self){
        _UIBusMessageQueue = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
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
-(UIViewController *) getResponseViewCtrl {
    UIViewController *ctrl = nil;
    if(_UIBusMessageQueue.count > 0){
        ctrl = [[_UIBusMessageQueue lastObject] objectForKey:TITLE_MESSAGERESULT];
        if(![ctrl isKindOfClass:[UIViewController class]]){
            ctrl =  nil;
        }
    }
    
    return ctrl;
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
        NSLog(@"LDUIBusCenter>> bundle list is empty>>");
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
                    if(action.ifNeedPresent){
                        success = [bundle.uibusConnetor dealWithURLMessageFromBus:action];
                    }
                    
                    //如果只是url实例化，则调用connetor返回
                    else {
                        UIViewController *ctrl = [bundle.uibusConnetor viewControllerForAction:action];
                        if(ctrl){
                            success = YES;
                            //存储结果
                            [_UIBusMessageQueue replaceObjectAtIndex:_UIBusMessageQueue.count-1 withObject:@{TITLE_MESSAGEACTION:action, TITLE_MESSAGERESULT:ctrl}];
                        }
                    }
                }
                break;
            }
            
        }
        
        isAllCheck = (i == keys.count)?YES:NO;
    }
    @catch (NSException *exception) {
        NSLog(@"LDUIBusCenter>> try via connetor create viewCtrl error>>");
    }
    @finally {
        //处理遍历所有bundle的map无法找到匹配url的情况
        if(isAllCheck){
            NSLog(@"LDUIBusCenter>> all bundles have no matched pattern>>");
        }
    }
    
    if(success){
        NSLog(@"LDUIBusCenter>> excute action success");
    }

    return success;
}












@end
