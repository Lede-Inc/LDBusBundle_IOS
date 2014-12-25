//
//  LDMUIBusCenter.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTURLAction;
@class TTURLActionResponse;
/**
 * @class LDUIBusCenter
 * UI总线调度中心, 负责接收从UIBusConnetor获取的URL消息，并负责将URL消息转发给其他所有bundle的connetor；
 */
@interface LDMUIBusCenter : NSObject {
}

+(LDMUIBusCenter *) uibusCenter;



//向UI总线发送消息，一个目的是为了跳转，另外一个目的是从其他Bundle获取ViewController
//向UI总线发送消息，发送成功返回YES
+(BOOL)sendUIMessage:(TTURLAction *)action;
//
+(UIViewController*)receiveURLCtrlFromUIBus:(TTURLAction *)action;
+(TTURLActionResponse *)handleURLActionRequest:(TTURLAction *)action;

/**
 * 从connetor获取action，存到当前容量为1的messageCache中；
 */
-(BOOL) getMessageFromConnetor:(TTURLAction *) action;

/**
 * 清空消息队列
 */
-(void) updateMessageQueue;

/**
 * 向其他所有接入总线的bundle转发消息
 */
-(BOOL) forwardMessageToOtherBundles;

/**
 * 获取messageQueue的响应ViewController
 */
-(TTURLActionResponse *) getURLActionResponse;
@end
