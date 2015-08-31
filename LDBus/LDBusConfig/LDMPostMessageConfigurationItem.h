//
//  LDMPostMessageConfigurationItem.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @class LDMPostMessageConfigurationItem
 * 存储一项发送消息配置选项
 */
@interface LDMPostMessageConfigurationItem : NSObject {
    NSString *_messageName;
    NSString *_messageCode;
}

@property (readonly, nonatomic) NSString *messageName;
@property (readonly, nonatomic) NSString *messageCode;

- (id)initWithPostMessageConfigurationItem:(NSString *)theMessageName
                                      code:(NSString *)theMessageCode;

@end
