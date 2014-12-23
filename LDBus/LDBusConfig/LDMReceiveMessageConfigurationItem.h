//
//  LDMReceiveMessageConfigurationItem.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class LDMReceiveMessageConfigurationItem
 * 存储一项接收消息配置
 */
@interface LDMReceiveMessageConfigurationItem : NSObject {
    NSString *_messageCode;
    NSString *_messageName;
    NSString *_receiveObjectString;
}

@property (readonly, nonatomic) NSString *messageCode;
@property (readonly, nonatomic) NSString *messageName;
@property (readonly, nonatomic) NSString *receiveObjectString;

-(id)initWithReceiveMessageConfigurationItem:(NSString *) theMessageName
                                        code:(NSString *) theMessageCode
                               receiveObject:(NSString *) theReceiveObjectString;

@end
