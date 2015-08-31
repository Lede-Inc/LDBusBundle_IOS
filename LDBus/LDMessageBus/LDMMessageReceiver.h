//
//  LDMMessageReceiver.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 所有消息的订阅者（接收消息的object）必须实现这个protocol
 */
@protocol LDMMessageReceiver <NSObject>
@required
- (void)didReceiveMessageNotification:(NSNotification *)notification;
@end
