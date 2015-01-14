//
//  LDFBundle.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const UNINSTALLED;
extern int const INSTALLED;
extern int const INSTALLING;// 正在下载安装
extern int const HAS_NEWVERSION;
extern int const STARTED;// 已启动
extern int const STOPPED;// 未启动

extern int const INSTALL_LEVEL_NONE;// 不自动安装
extern int const INSTALL_LEVEL_WIFI;// 仅WIFI下自动安装
extern int const INSTALL_LEVEL_ALL;// 任意网络下均自动安装


/**
 * @class 组件Bundle
 * 主要用来加载动态组件（dynamic framework）, 直接读取framework内部的info.plist
 */
@interface LDFBundle : NSObject {

}


@property (nonatomic) int state; ////当前的安装状态
@property (nonatomic) long crc32; //ipa包的CRC校验值
@property (nonatomic, readonly) NSMutableDictionary *infoDictionary;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *name; //组件显示名字
@property (nonatomic, readonly) NSString *updateURL;//组件更新地址
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) NSString *versionCode;
@property (nonatomic, readonly) BOOL autoStartup;
@property (nonatomic, readonly) long size;
@property (nonatomic, readonly) NSString* installLocation;
@property (nonatomic, readonly) Class principalClass;
@property (nonatomic, readonly) NSString *exportServices; //获取bundle支持的服务
@property (nonatomic, readonly) NSString *importServices; //获取bundle需要引入的服务
@property (nonatomic, readonly) int autoInstallLevel; //获取bundle的自动安装的网络级别
@property (nonatomic, readonly) NSString *minFrameworkVersion; //要求的最低框架版本
@property (nonatomic, readonly) NSString *minHostAppVersion; //要求主程序的最低版本

/**
 * 根据远程组件的属性初始化一个bundle
 */
-(id)initBundleWithInfoDictionary:(NSDictionary *)theInfoDictionary;


/**
 * 根据framework的路径初始化一个bundle
 */
-(id)initBundleWithPath:(NSString *)path;


/**
 * 根据framwork的路径和IOSVersion初始化动态库对象
 */
-(BOOL)instanceDynamicBundle:(NSString *)path;


/**
 * 组件启动
 */
-(BOOL)start;


/**
 * 组件停止
 */
-(BOOL)stop;


/**
 * 判断组件是否启动
 */
-(BOOL)isLoaded;


/**
 * 判断两个组件是否相同
 */
-(BOOL)isEqual:(id)obj;


@end
