//
//  LDMServiceBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMServiceBusCenter.h"
#import "LDMBusContext.h"

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
            NSString *serviceClass = [dic objectForKey:TITLE_SERVICEBUSCLASS];
            Class class = [NSClassFromString(serviceClass) class];
            if(class != nil){
                serviceImpl = [[class alloc] init];
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
-(BOOL) registerServiceToBusBatchly: (NSMutableDictionary *) dic {
    if(dic && dic.allKeys.count > 0){
        NSArray *keysArray = dic.allKeys;
        for(int i = 0; i < keysArray.count; i++){
            NSString *serviceName = [keysArray objectAtIndex:i];
            NSString *serviceClass = [dic objectForKey:serviceName];
            if([NSClassFromString(serviceClass) class] != nil){
                [_serviceMap setObject:@{TITLE_SERVICEBUSCLASS:serviceClass,
                                         TITLE_SERVICEBUSOBJECT:[NSNull null]}
                                forKey:[serviceName lowercaseString]];
            }
        }
    }
    
    return YES;
}


/**
 * 通过key-value给服务总线注册服务
 *
 */
-(BOOL) registerServiceToBus:(NSString *)serviceName withServiceClass:(NSString *)serviceClass {
    if([NSClassFromString(serviceClass) class] != nil){
        [_serviceMap setObject:@{TITLE_SERVICEBUSCLASS:serviceClass,
                                 TITLE_SERVICEBUSOBJECT:[NSNull null]}
                        forKey:[serviceName lowercaseString]];
    }
    return YES;
}


/**
 * 批量注销服务
 */
-(BOOL) unRegisterServiceFromBusBatchly:(NSArray *)services {
    if(services && services.count > 0){
        for(int i = 0; i < services.count; i++){
            [self unRegisterServiceFromBus:[services objectAtIndex:i]];
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
