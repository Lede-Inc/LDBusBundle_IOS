//
//  LDMServiceBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMServiceBusCenter.h"
#import "LDMBusContext.h"
#import "LDMServiceConfigurationItem.h"

#define TITLE_SERVICEBUSCLASS @"servicebus_implclass"
#define TITLE_SERVICEBUSOBJECT  @"servicebus_implobject"

static LDMServiceBusCenter *servicebusCenter = nil;
@interface LDMServiceBusCenter () {
    NSMutableDictionary *_serviceMap;
}

@end

@implementation LDMServiceBusCenter


+(LDMServiceBusCenter *) servicebusCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicebusCenter = [[self alloc] init];
    });
    return servicebusCenter;
}


-(id) init {
    self = [super init];
    if(self){
        _serviceMap = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return self;
}

/**
 * 从服务总线中获取某个服务的实现
 */
-(id) getServiceImpl:(NSString *)serviceName {
    //根据serviceName获取在服务总线上的注册
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[_serviceMap objectForKey:[serviceName lowercaseString]]];
    
    //如果服务存在，检查服务是否启动，如果未启动，马上启动，并返回service实例
    id serviceImpl = nil;
    if(dic){
        if([dic objectForKey:TITLE_SERVICEBUSOBJECT] == [NSNull null]){
            Class serviceClass = [dic objectForKey:TITLE_SERVICEBUSCLASS];
            if(serviceClass != nil){
                serviceImpl = [[serviceClass alloc] init];
                [dic setObject:serviceImpl forKey:TITLE_SERVICEBUSOBJECT];
                [_serviceMap setObject:dic forKey:[serviceName lowercaseString]];
            }
        } else {
            serviceImpl = [dic objectForKey:TITLE_SERVICEBUSOBJECT];
        }
    }
    
    return serviceImpl;
}



/**
 * 通过map数组给服务总线中注册服务
 */
-(BOOL) registerServiceToBusBatchly: (NSArray *) serviceConfigurationList{
    if(serviceConfigurationList && serviceConfigurationList.count > 0){
        for(int i = 0; i < serviceConfigurationList.count; i++){
            LDMServiceConfigurationItem *serviceItem = [serviceConfigurationList objectAtIndex:i];
            [self registerServiceToBus:serviceItem.serviceName
                                 class:serviceItem.classString
                              protocol:serviceItem.protocolString];
        }
    }
    
    return YES;
}


/**
 * 通过key-value给服务总线注册服务
 *
 */
-(BOOL) registerServiceToBus:(NSString *)serviceName
                       class:(NSString *)serviceClassString
                    protocol:(NSString *)serviceProtocolString{
    BOOL success = NO;
    Class serviceClass = nil;
    if(serviceClassString && ![serviceClassString isEqualToString:@""]){
        serviceClass = NSClassFromString(serviceClassString);
    }
    
    Protocol *serviceProtocol = nil;
    if(serviceProtocolString && ![serviceProtocolString isEqualToString:@""]){
        serviceProtocol = NSProtocolFromString(serviceProtocolString);
    }
    
    //如果serviceClass 在bundle中不存在，不注册该服务
    if(serviceClass && serviceProtocol && [serviceClass conformsToProtocol:serviceProtocol]){
        if([_serviceMap objectForKey:[serviceName lowercaseString]] != nil){
            //注册的时候给予提醒，不允许相同服务名称进行注册，不区分大小写，有重复不予覆盖
#ifdef DEBUG
            NSAssert(NO, @"service: %@ duplicate register in service bus", serviceName);
#endif
        } else {
            [_serviceMap setObject:@{TITLE_SERVICEBUSCLASS:serviceClass,
                                 TITLE_SERVICEBUSOBJECT:[NSNull null]}
                        forKey:[serviceName lowercaseString]];
            success = YES;
        }
    }
    
    return success;
}


/**
 * 批量注销服务
 */
-(BOOL) unRegisterServiceFromBusBatchly:(NSArray *)serviceNames;{
    if(serviceNames && serviceNames.count > 0){
        for(int i = 0; i < serviceNames.count; i++){
            [self unRegisterServiceFromBus:[serviceNames objectAtIndex:i]];
        }
    }
    
    return YES;
}


/**
 * 按service名称注销服务
 */
-(BOOL) unRegisterServiceFromBus:(NSString *) serviceName {
    if([_serviceMap objectForKey:[serviceName lowercaseString]] != nil){
        [_serviceMap removeObjectForKey:[serviceName lowercaseString]];
    }
    
    return YES;
}



@end


/**
 * 实现service总线供外界调用的方法
 */
@implementation LDMBusContext(LDServiceBusCenter)
+(id)getService:(NSString *)serviceName{
    return [[LDMServiceBusCenter servicebusCenter] getServiceImpl:serviceName];
}

@end
