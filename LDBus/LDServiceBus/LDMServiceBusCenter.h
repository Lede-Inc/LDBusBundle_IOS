//
//  LDMServiceBusCenter.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class LDServiceBusCenter
 * service总线调度中心
 */
@interface LDMServiceBusCenter : NSObject{
    
}

+(LDMServiceBusCenter *)servicebusCenter;

/**
 * 从服务总线中获取某个服务的实现
 */
-(id) getServiceImpl:(NSString *)serviceName;


/**
 * 通过map数组给服务总线中注册服务
 */
-(BOOL) registerServiceToBusBatchly: (NSArray *) serviceConfigurationList;

/**
 * 通过key-value给服务总线注册服务
 *
 */
-(BOOL) registerServiceToBus:(NSString *)serviceName
                       class:(NSString *)serviceClassString
                    protocol:(NSString *)serviceProtocolString;

/**
 * 批量注销服务
 */
-(BOOL) unRegisterServiceFromBusBatchly:(NSArray *)serviceNames;

/**
 * 按service名称注销服务
 */
-(BOOL) unRegisterServiceFromBus:(NSString *) serviceName;


@end
