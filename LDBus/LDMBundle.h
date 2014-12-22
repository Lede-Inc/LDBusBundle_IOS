//
//  LDMBundle.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UNINSTALLED = 1,        // 未安装
    INSTALLED = 2,          // 已安装
    INSTALLING = 4,         // 正在下载安装
    HAS_NEWVERSION = 8,     // 存在新版本
    STARTED = 16,           // 已启动
    STOPPED = 32            // 未启动
}BundleState;


typedef enum {
    INSTALL_LEVEL_NONE = 0, // 不自动安装
    INSTALL_LEVEL_WIFI = 1, // 仅WIFI下自动安装
    INSTALL_LEVEL_ALL = 2   // 任意网络下均自动安装
}InstallLevel;

/**
 * @class LDMBundle
 * 定义bundle的基本属性、启动、加载、停止
 * 1. 目前每个bundle编译成static framework，集成到主工程之后统一编译成一个bundle
 * 2. 如果编译成动态库，可以直接通过NSBundle进行管理, 为了方便以后扩展，直接继承NSBundle
 */

@class LDMNavigator;
@class TTFrameworkBundleObj;
@class LDMUIBusConnector;
@interface LDMBundle : NSBundle {
    //bundle的下载地址，由每个bundle自己完成更新
    NSString *_updateURL;
    //记录自动下载安装的网络级别
    InstallLevel _installLevel;
    //记录当前bundle的状态
    BundleState  _state;
    
    //是否动态加载
    BOOL _isDynamic;
    
    //bundle config解析对象
    TTFrameworkBundleObj *_configObj;
    
    //bundle的UIBus connetor
    //如果自定义connector，必须继承busconnetor并遵循busconnetor的服务协议；
    LDMUIBusConnector *_uibusConnetor;
    LDMNavigator *_navigator;
    NSString *_scheme;
}

@property (readonly, copy) NSString *updateURL;
@property (readonly) InstallLevel InstallLevel;
@property (readonly) BundleState state;
@property (readonly) BOOL isDynamic;
@property (readonly) LDMUIBusConnector *uibusConnetor;
@property (readonly) NSString *scheme;


/**
 * 根据bundle下载的指定位置初始化Bundle，
 * static:  现在bundle的static framework是直接link到主bundle的;
 *          指定位置是一个以.bundle为扩展名的资源bundle，里面只有配置文件
 * dynamic: 如果系统是ios7及以上的，探索是不是可以直接下载dynamic framework
 *          一些独立的功能可以考虑在ios7的机器上先进行投放
 *          指定位置是一个以.framework为扩展名的动态库bundle，可以直接从动态库里读取配置文件
 */
-(id) initBundleWithPath:(NSString *)path;
-(void)setBundleNavigator:(LDMNavigator *)navigator;
-(void)setBundleScheme:(NSString *)scheme;


/**
 * 给当前bundle初始化一个connector
 * 如果bundle配置文件指定connetorClass，则初始化一个指定的connetor给
 * 否则初始化一个默认的connetor给bundle
 */
-(BOOL) setUIBusConnectorToBundle;


/**
 * 从config中获取服务总线配置
 */
-(NSMutableDictionary* ) getServiceMapFromConfigObj;

/**
 * 从config中获取消息总线配置
 */
-(NSMutableDictionary *) getMessageMapFromConfigObj;

@end
