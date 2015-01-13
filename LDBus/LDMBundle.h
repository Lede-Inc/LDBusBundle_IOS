//
//  LDMBundle.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * @class LDMBundle
 * 定义bundle关于Bus的配置文件属性
 */

@class LDMNavigator;
@class LDMBundleConfigurationItem;
@class LDMUIBusConnector;
@interface LDMBundle : NSObject {
    //bundle config解析对象
    LDMBundleConfigurationItem* _configurationItem;
    
    //bundle的UIBus connetor
    //如果自定义connector，必须继承busconnetor并遵循busconnetor的服务协议；
    LDMUIBusConnector *_uibusConnetor;
    LDMNavigator *_navigator;
    NSString *_scheme;
}

@property (readonly,nonatomic) NSString *bundleName;
@property (readonly) LDMUIBusConnector *uibusConnetor;
@property (readonly,nonatomic) LDMBundleConfigurationItem *configurationItem;
@property (readonly) NSString *scheme;


/**
 * 根据bundle下载的指定位置初始化Bundle，
 *   关于Bus的配置：指定位置是一个以.bundle为扩展名的资源bundle，里面只有配置文件
 */
-(id) initBundleBusConfigWithPath:(NSString *)path;
-(void)setBundleNavigator:(LDMNavigator *)navigator;
-(void)setBundleScheme:(NSString *)scheme;


/**
 * 给当前bundle初始化一个connector
 * 如果bundle配置文件指定connetorClass，则初始化一个指定的connetor给
 * 否则初始化一个默认的connetor给bundle
 */
-(BOOL) setUIBusConnectorToBundle;


/**
 * 从config中获取bundle服务配置项列表
 */
-(NSArray* ) getServiceConfigurationList;


/**
 * 从config中获取bundle发送消息配置项列表
 */
-(NSArray *) getPostMessageConfigurationList;


/**
 * 从config中获取bundle接受消息配置项列表
 */
-(NSArray *) getReceiveMessageConfigurationList;


/**
 * 和容器内的其他bundle进行比较，是否有重复的URLPattern
 */
-(void) checkDuplicateURLPattern:(LDMBundle *)aBundle;


@end
