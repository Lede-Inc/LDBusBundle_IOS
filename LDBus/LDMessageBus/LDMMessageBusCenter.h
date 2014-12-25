//
//  LDMMessageBusCenter.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class LDMMessageBusCenter
 * message总线调度中心 主要为了跟android的intent广播消息保持一致
 * 其主要作用不同于notificationcenter，主要是定义了Notification handler机制
 */

@interface LDMMessageBusCenter : NSObject {
    NSMutableDictionary *_messageReceiveItemList; //是指消息中心接收notification的Object
    NSMutableDictionary *_listeningNotifications; //是指消息中心监控的Notification
}


+(LDMMessageBusCenter *) messagebusCenter;


/**
 * 根据MessageName获取MessageCode
 * 从监听notification中获取
 */
-(NSString *)messageCodeForName:(NSString *)messageName;


/**
 * 当收到notification时，检测notification是否注册
 * 然后将Notification转发给所有的监听者
 */
-(void) didReceiveMessageNotification:(NSNotification *)notification;


/**
 * 注册notification监听者
 */
-(void) regitsterMessageReceivers:(NSArray *)receiveMessageConfigurationList;



/**
 * 向消息总线中注册监听的notification
 */
-(void)registerListeningNotificationBatchly: (NSArray*)postMessageConfigurationList;
-(void)registerListeningNotification: (NSString *)postMessageName code:(NSString *)postMessageCode;


/**
 * 批量注销监听的notification
 */
-(void) unRegisterListeningNotificationBatchly:(NSArray *)postMessageNames;


/**
 * 按postMessageNames注销监听
 */
-(void) unRegisterListeningNotification:(NSString *) postMessageName;



@end
