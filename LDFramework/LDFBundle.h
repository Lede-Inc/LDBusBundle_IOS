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
 * 如果是静态组件（static framework), 不初始化完成，只是完成基本属性的管理，将info.plist拷贝到资源配置文件夹中
 * 不管是动态还是静态，均对总线进行管理
 */
@interface LDFBundle : NSBundle {

}
//当前的安装状态
@property (nonatomic) int state;

/**
 * 组件启动
 */
-(BOOL)start;

/**
 * 组件停止
 */
-(BOOL)stop;

/**
 * 获取当前组件状态
 */
-(int)state;

/**
 * 组件显示名
 */
-(NSString*)name;

/**
 * 组件的bundle identifier
 */
-(NSString *)identifier;

/**
 * 组件的版本号 和 build版本号
 */
-(NSString *)version;
-(int) versionCode;


/**
 * 组件的入口class
 */
-(Class) principalClass;


/**
 * 组件的初始化路径
 */
-(NSString *) installLocation;


/**
 * 组件的大小
 */
-(long) size;


/**
 * 组件的更新地址
 */
-(NSString *) updateUrl;

@end
