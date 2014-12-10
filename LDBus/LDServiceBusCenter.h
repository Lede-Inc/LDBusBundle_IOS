//
//  LDServiceBusCenter.h
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
@interface LDServiceBusCenter : NSObject{
    
}

+(LDServiceBusCenter *)servicebusCenter;
/**
 * 通过map数组给服务总线中注册服务
 */
-(BOOL) registerServiceToBusBatchly: (NSMutableDictionary *) dic;

/**
 * 从服务总线中获取某个服务的实现
 */
-(id) getServiceImpl:(NSString *)serviceName;

/**
 * 通过key-value给服务总线注册服务
 *
 */
-(BOOL) registerServiceToBus:(NSString *)serviceName withServiceClass:(NSString *)serviceClass;

/**
 * 批量注销服务
 */
-(BOOL) unRegisterServiceFromBusBatchly:(NSArray *)services;

/**
 * 按service名称注销服务
 */
-(BOOL) unRegisterServiceFromBus:(NSString *) serviceName;


@end
