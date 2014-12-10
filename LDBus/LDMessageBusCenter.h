//
//  LDMessageBusCenter.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * @class LDServiceBusCenter
 * message总线调度中心
 */
@interface LDMessageBusCenter : NSObject {
    
}
+(LDMessageBusCenter *) messagebusCenter;

/**
 * 向消息总线操作注册消息Object的实例化标志
 */
-(BOOL)operateNotificationObserverToMessageBus: (id)observer selector:(SEL)selector withMessage:(NSString *)messageName  andAObject:(id) aobject option:(int)option;


/**
 * 向注册消息的所有viewController发送通知
 */
-(BOOL)postNotificaitonToAllResponseViewController:(NSNotification *)notification;


/**
 * 通过map数组向消息总线中注册允许通信的消息
 * 每个bundle通过配置文件告诉消息总线需要发送什么消息
 */
-(BOOL) registerMessageToBusBatchly: (NSMutableDictionary *) dic;

/**
 * 通过key-value给消息总线注册消息
 *
 */
-(BOOL) registerMessageToBus:(NSString *)messageName withMessageClass:(NSString *)messageClass;

/**
 * 批量注销消息
 */
-(BOOL) unRegisterMessageFromBusBatchly:(NSArray *)messages;

/**
 * 按service名称注销服务
 */
-(BOOL) unRegisterMessageFromBus:(NSString *) message;



@end
