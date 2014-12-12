//
//  LDMessageBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMessageBusCenter.h"
#import "LDBusContext.h"

#define TITLE_MESSAGEBUSPOSTCLASS @"messagebus_postclass"
#define TITLE_MESSAGEBUSRECVOBJCOUNT @"messagebus_recvobjcount"


static LDMessageBusCenter *messagebusCenter = nil;
@interface LDMessageBusCenter () {
    NSMutableDictionary *_messageMap;
    NSNotificationCenter *_center;
}
@end



@implementation LDMessageBusCenter

+(LDMessageBusCenter *) messagebusCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messagebusCenter = [[self alloc] init];
    });
    return messagebusCenter;
}

-(id) init {
    self = [super init];
    if(self){
        _messageMap = [[NSMutableDictionary alloc] initWithCapacity:2];
        _center = [NSNotificationCenter defaultCenter];
    }
    return self;
}


/**
 * 向消息总线操作注册消息Object的实例化标志
 */
-(BOOL)operateNotificationObserverToMessageBus: (id)observer selector:(SEL)selector withMessage:(NSString *)messageName  andAObject:(id) aobject option:(int)option{
    BOOL success = NO;
    NSArray *keys = _messageMap.allKeys;
    for(int i=0; i<keys.count; i++){
        NSString *key = [keys objectAtIndex:i];
        if([key hasSuffix:[messageName lowercaseString]]){
            NSDictionary *dic = [_messageMap objectForKey:key];
            NSString *className = [dic objectForKey:TITLE_MESSAGEBUSPOSTCLASS];
            NSInteger initCount = [[dic objectForKey:TITLE_MESSAGEBUSRECVOBJCOUNT] intValue];
            //当前监听object不允许为nil
            if(observer != nil){
                [_messageMap setObject:@{TITLE_MESSAGEBUSPOSTCLASS:className,
                                         TITLE_MESSAGEBUSRECVOBJCOUNT:(option?@(initCount+1):@(initCount-1))}
                                forKey:key];
                if(option){
                    [_center addObserver:observer
                                selector:selector
                                    name:messageName
                                  object:aobject];
                } else {
                    [_center removeObserver:observer
                                       name:messageName
                                     object:aobject];
                }
                success = YES;
                break;
            }
        }
    }
    return success;
}



/**
 * 向注册消息的所有viewController发送通知
 */
-(BOOL)postNotificaitonToAllResponseViewController:(NSNotification *)notification{
    //当当前的消息总线中是否有订阅才发射消息，这里做了一个中心hook
    //实际情况不管有没有订阅，消息中心均可以发射消息，但是两者效果一致
    BOOL success = NO;
    if([self isMessageValid:notification.name]){
        [_center postNotification:notification];
        success = YES;
    }
    return success;
}


/**
 * 判断当前发送的消息是否在消息总线注册，是否有object响应
 */
-(BOOL)isMessageValid:(NSString *) messageName {
    BOOL isValid = NO;
    NSArray *keys = _messageMap.allKeys;
    for(int i=0; i<keys.count; i++){
        NSString *key = [keys objectAtIndex:i];
        if([key hasSuffix:[messageName lowercaseString]]){
            NSDictionary *dic = [_messageMap objectForKey:key];
            //检测当前是否有object响应,通过订阅消息者是否大于0
            if([[dic objectForKey:TITLE_MESSAGEBUSRECVOBJCOUNT] intValue]>0){
                isValid = YES;
                break;
            }
        }
    }
    
    return isValid;
}


/**
 * 通过map数组给服务总线中注册服务
 */
-(BOOL) registerMessageToBusBatchly: (NSMutableDictionary *) dic {
    if(dic && dic.allKeys.count > 0){
        NSArray *keysArray = dic.allKeys;
        for(int i = 0; i < keysArray.count; i++){
            NSString *messageName = [keysArray objectAtIndex:i];
            NSString *messageClass = [dic objectForKey: messageName];
            if([NSClassFromString(messageClass) class] != nil){
                [_messageMap setObject: @{TITLE_MESSAGEBUSPOSTCLASS:messageClass,
                                          TITLE_MESSAGEBUSRECVOBJCOUNT:@0}
                                forKey:[ messageName lowercaseString]];
            }
        }
    }
    
    return YES;
}


/**
 * 通过key-value给服务总线注册服务
 *
 */
-(BOOL) registerMessageToBus:(NSString *) messageName withMessageClass:(NSString *) messageClass {
    if([NSClassFromString(messageClass) class] != nil){
        [_messageMap setObject:@{TITLE_MESSAGEBUSPOSTCLASS:messageClass,
                                 TITLE_MESSAGEBUSRECVOBJCOUNT:@0}
                        forKey:[messageName lowercaseString]];
    }
    return YES;
}


/**
 * 批量注销服务
 */
-(BOOL) unRegisterMessageFromBusBatchly:(NSArray *)messages {
    if(messages && messages.count > 0){
        for(int i = 0; i < messages.count; i++){
            [self unRegisterMessageFromBus:[messages objectAtIndex:i]];
        }
    }
    
    return YES;
}


/**
 * 按service名称注销服务
 */
-(BOOL) unRegisterMessageFromBus:(NSString *) messageName {
    if([_messageMap objectForKey:[messageName lowercaseString]] != nil){
        [_messageMap removeObjectForKey:[messageName lowercaseString]];
    }
    
    return YES;
}

@end



/**
 * 共所有bundle的所有controller调用
 */
@implementation LDBusContext (LDMessageBusCenter)
/**
 * 向消息总线添加观察者
 */
+(BOOL )addObserver:(id)observer sel:(SEL)sel  message:(NSString *)message aObject: (id)aObject{
    return [[LDMessageBusCenter messagebusCenter] operateNotificationObserverToMessageBus:observer selector:sel withMessage:message andAObject:aObject option:1];
}

/**
 * 向消息总线移除观察者
 */
+(BOOL)removeObserver:(id)observer message:(NSString *) message aObject:(id)aObject{
    return [[LDMessageBusCenter messagebusCenter] operateNotificationObserverToMessageBus:observer selector:nil withMessage:message andAObject:aObject option:0];
}

/**
 * 向消息总线的所有观察者发送消息
 */
+(BOOL)postMessage:(NSString *)message{
    NSNotification *notification =  [NSNotification notificationWithName:message object:nil];
    return [[LDMessageBusCenter messagebusCenter] postNotificaitonToAllResponseViewController:notification];
}

+(BOOL)postMessage:(NSString *) message object:(id) object{
    NSNotification *notification =  [NSNotification notificationWithName:message object:object];
    return [[LDMessageBusCenter messagebusCenter] postNotificaitonToAllResponseViewController:notification];
}

+(BOOL)postMessage:(NSString *)message userInfo:(NSDictionary *)aUserInfo{
    NSNotification *notification =  [NSNotification notificationWithName:message object:nil userInfo:aUserInfo];
    return [[LDMessageBusCenter messagebusCenter] postNotificaitonToAllResponseViewController:notification];
}



@end