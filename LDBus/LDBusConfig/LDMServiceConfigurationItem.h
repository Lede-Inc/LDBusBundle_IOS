//
//  LDMServiceConfigurationItem.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class LDMServiceConfigurationItem 
 * 存储一个Service配置选项
 */
@interface LDMServiceConfigurationItem : NSObject {
    NSString *_serviceName;
    NSString *_protocolString;
    NSString *_classString;
}

@property (readonly, nonatomic)NSString *serviceName;
@property (readonly, nonatomic)NSString *protocolString;
@property (readonly, nonatomic)NSString *classString;

-(id)initWithServiceConfigurationItem:(NSString *)theServiceName
                             protocol:(NSString *)theProtocolString
                                class:(NSString *)theClassString;

@end
