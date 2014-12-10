//
//  LDBusContext.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/10/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTURLAction;
@interface LDBusContext : NSObject

@end

/**
 * @Category LDUIBusConnector
 * UI总线的调用，通过UIConnetor调用，具体的UI总线透明
 */
@interface LDBusContext (LDUIBusConnector)
/**
 * 向当前bundle的connector 发送action消息
 */
+(BOOL)sendURLToConnectorWithAction:(TTURLAction *)action;

/**
 * 向当前bundle的Connetor 发送URL消息
 */
+(BOOL)sendURLToConnector:(NSString *)url;

/**
 * 向当前bundle的connector 发送url和query组装消息
 */
+(BOOL)sendURLToConnectorWithQuery:(NSString *)url query:(NSDictionary *)query;

/**
 * 向当前bundle的connetor 申请某个url对应的ctrl；
 */
+(UIViewController *)receiveURLCtrlFromConnetor:(NSString *)url;

@end





/**
 * @Category LDServiceBusCenter
 * 服务总线的调用
 */
@interface LDBusContext (LDServiceBusCenter)

/**
 * 从服务总线获取服务的实例
 */
+(id)getServiceFromBus:(NSString *)serviceName;

@end





/**
 * @Category LDMessageBusCenter
 * 消息总线的调用
 */
@interface LDBusContext (LDMessageBusCenter)
/**
 * 向消息总线添加观察者
 */
+(BOOL )addObserverToMessageBus:(id)observer sel:(SEL)sel  message:(NSString *)message aObject: (id)aObject;
/**
 * 向消息总线移除观察者
 */
+(BOOL)removeObserverFromMessageBus:(id)observer message:(NSString *) message aObject:(id)aObject;

/**
 * 向消息总线的所有观察者发送消息
 */
+(BOOL)postMessageToBus:(NSString *)message;
+(BOOL)postMessageToBusWithObject:(NSString *) message object:(id) object;
+(BOOL)postMessageToBusWithUserInfo:(NSString *)message userInfo:(NSDictionary *)aUserInfo;


@end
