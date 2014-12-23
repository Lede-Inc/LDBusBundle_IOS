//
//  LDMMessageBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMMessageBusCenter.h"
#import "LDMBusContext.h"

#import "LDMPostMessageConfigurationItem.h"
#import "LDMReceiveMessageConfigurationItem.h"
#import "LDMMessageReceiver.h"


#define TITLE_MESSAGEBUSPOSTCLASS @"messagebus_postclass"
#define TITLE_MESSAGEBUSRECVOBJCOUNT @"messagebus_recvobjcount"


static LDMMessageBusCenter *messagebusCenter = nil;
@implementation LDMMessageBusCenter

+(LDMMessageBusCenter *) messagebusCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messagebusCenter = [[self alloc] init];
    });
    return messagebusCenter;
}

-(id) init {
    self = [super init];
    if(self){
        _listeningNotifications = [[NSMutableDictionary alloc] initWithCapacity:2];
        _messageReceiveItemList = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}


/**
 * 根据MessageName获取MessageCode
 * 从监听notification中获取
 */
-(NSString *)messageCodeForName:(NSString *)messageName{
    NSString *messageCode = nil;
    if(_listeningNotifications && _listeningNotifications.allKeys.count >0){
        messageCode = [_listeningNotifications objectForKey:messageName];
    }
    
    return  messageCode;
}


/**
 * 当收到notification时，检测notification是否注册
 * 然后将Notification转发给所有的监听者
 */
-(void) didReceiveMessageNotification:(NSNotification *)notification{
    NSString *messageCode = [self messageCodeForName:notification.name];
    //如果当前messagecode是消息总线监听的messageCode
    if(messageCode){
        NSMutableArray *oneReceiverList = [_messageReceiveItemList objectForKey:messageCode];
        if(oneReceiverList && oneReceiverList.count > 0){
            for(int i = 0; i < oneReceiverList.count; i++){
                id<LDMMessageReceiver> messageReceiver = [oneReceiverList objectAtIndex:i];
                [messageReceiver didReceiveMessageNotification:notification];
            }
        }
    }
}


/**
 * 注册notification监听者
 * 只要求传MessageCode
 * 监听者默认都是notification的handler，所以默认初始化一个handler的实例
 */
-(void) regitsterMessageReceivers:(NSArray *)receiveMessageConfigurationList{
    if(receiveMessageConfigurationList && receiveMessageConfigurationList.count > 0) {
        Protocol *messageReceiveProtocol = NSProtocolFromString(@"LDMMessageReceiver");
        for(int i = 0; i < receiveMessageConfigurationList.count; i++){
            LDMReceiveMessageConfigurationItem *receiveMessageConfigurationItem =  [receiveMessageConfigurationList objectAtIndex:i];
#ifdef DEBUG
            assert(receiveMessageConfigurationItem.messageCode != nil && ![receiveMessageConfigurationItem.messageCode isEqualToString:@""]);
#endif
            NSMutableArray *oneReceiverList = [_messageReceiveItemList objectForKey:receiveMessageConfigurationItem.messageCode];
            //如果为设置，初始化一个接收者池子
            if(oneReceiverList == nil){
                oneReceiverList = [[NSMutableArray alloc] initWithCapacity:2];
                [_messageReceiveItemList setObject:oneReceiverList forKey:receiveMessageConfigurationItem.messageCode];
            }
            
            //检查handler并且实例化
#ifdef DEBUG
            assert(receiveMessageConfigurationItem.receiveObjectString != nil && ![receiveMessageConfigurationItem.receiveObjectString isEqualToString:@""]);
#endif
            Class receiveObjectClass = NSClassFromString(receiveMessageConfigurationItem.receiveObjectString);
            if(receiveObjectClass != nil &&
               [receiveObjectClass conformsToProtocol:messageReceiveProtocol]){
                //验证接受hander是否已经存在
                BOOL isexist = NO;
                for(int index = 0; index < oneReceiverList.count; index++){
                    id tmpObject = [oneReceiverList objectAtIndex:index];
                    if([tmpObject class] == receiveObjectClass){
                        isexist = YES;
                        break;
                    }
                }
                
                //如果不存在，将handler加入到该messageCode的订阅者列表中
                if(!isexist){
                    id<LDMMessageReceiver> receiveObject = [[receiveObjectClass alloc] init];
                    [oneReceiverList addObject:receiveObject];
                }
            }//if
            
            else {
#ifdef DEBUG
                //检查receiveObjectClass是否定义，以及是否遵循事件处理机制
                    NSAssert(NO, @"messageReceiver: %@ has invalid object receiver (%@) in message bus", receiveMessageConfigurationItem.messageName, receiveMessageConfigurationItem.receiveObjectString);
#endif
            }
            
        }//for
    }//if
}


/**
 * 向消息总线中注册监听的notification
 */
-(void)registerListeningNotificationBatchly: (NSArray*)postMessageConfigurationList{
    if(postMessageConfigurationList && postMessageConfigurationList.count > 0){
        for(int i = 0; i < postMessageConfigurationList.count; i++){
            LDMPostMessageConfigurationItem *postMessageConfigurationItem = [postMessageConfigurationList objectAtIndex:i];
            //在parse的时候已经确保没有空参数传入
            [self registerListeningNotification:postMessageConfigurationItem.messageName code:postMessageConfigurationItem.messageCode];
        }
    }
}

-(void)registerListeningNotification: (NSString *)postMessageName code:(NSString *)postMessageCode{
    if((postMessageName && ![postMessageName isEqualToString:@""])
       && (postMessageCode && ![postMessageCode isEqualToString:@""])){
        if([_listeningNotifications objectForKey:postMessageName] != nil){
            //注册的时候给予提醒，不允许注册相同名称的消息事件，区分大小写, 有重复不予覆盖
#ifdef DEBUG
            NSAssert(NO, @"postMessage: %@ duplicate register in message bus", postMessageName);
#endif
        } else {
            [_listeningNotifications setObject:postMessageCode forKey:postMessageName];
        }
    }
}





/**
 * 批量注销监听的notification
 */
-(void) unRegisterListeningNotificationBatchly:(NSArray *)postMessageNames{
    if(postMessageNames && postMessageNames.count > 0){
        for(int i = 0; i < postMessageNames.count; i++){
            NSString *postMessageName = [postMessageNames objectAtIndex:i];
            [self unRegisterListeningNotification:postMessageName];
        }
    }
}


/**
 * 按postMessageName注销监听
 */
-(void) unRegisterListeningNotification:(NSString *) postMessageName{
    if(postMessageName && ![postMessageName isEqualToString:@""]){
        if([_listeningNotifications objectForKey:postMessageName] != nil){
            [_listeningNotifications removeObjectForKey:postMessageName];
        }
    }
}

@end



/**
 * 共所有bundle的所有controller调用
 */
@implementation LDMBusContext (LDMessageBusCenter)
/**
 * 向消息总线的所有观察者发送消息
 */
+(void)postMessage:(NSString *)message{
    NSNotification *notification =  [NSNotification notificationWithName:message object:nil];
   [self postNotification:notification];
}

+(void)postMessage:(NSString *) message object:(id) object{
    NSNotification *notification =  [NSNotification notificationWithName:message object:object];
    [self postNotification:notification];
}

+(void)postMessage:(NSString *)message userInfo:(NSDictionary *)aUserInfo{
    NSNotification *notification =  [NSNotification notificationWithName:message object:nil userInfo:aUserInfo];
    [self postNotification:notification];
}

+(void)postNotification:(NSNotification *)notification{
    [[LDMMessageBusCenter messagebusCenter] didReceiveMessageNotification:notification];
}



@end