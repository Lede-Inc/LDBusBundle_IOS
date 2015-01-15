//
//  LDFBundleContainer.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDFBundle.h"


extern NSString * const NOTIFICATION_BUNDLE_INSTALLED;
extern NSString * const NOTIFICATION_BUNDLE_UNINSTALLED;
extern NSString * const NOTIFICATION_BOOT_COMPLETED;



/**
 * Container加载监控器
 */
@protocol LDFBundleManagerListener <NSObject>
-(void)onFinish:(int) statusCode;
@end



/**
 * bundleContainer给外界提供下载进度监控，由外界自定义下载界面
 */
@protocol LDFBundleManagerDownloadListener <NSObject>
//是否下载结束
-(void)managerDownloadOnFinish:(long long) statusCode;
//下载进度
-(void)managerDownloadOnProgress:(long long) written total:(long long) total;
@end



/**
 * @class 管理整个应用的组件检查、下载、安装和启动
 * 控制一个单例
 */
@protocol LDFBundleDownloadListener;
@interface LDFBundleManager : NSObject {
    
}

+(instancetype)sharedContainer;

/**
 * 启动bundle容器
 */
-(void)bootBundleManagerWithListener:(id<LDFBundleManagerListener>) listener;


/**
 * 返回是否需要重启
 */
-(BOOL) isNeedReboot;


/**
 * 判断bundle容器是否启动完毕
 */
-(BOOL)isBootCompleted;


/**
 * 获取本地和服务器端的所有可安装组件列表
 */
-(NSArray *)getAllBundles;


/**
 * 获取远端服务器可安装的组件列表
 */
-(NSArray *)getRemoteBundles;

/**
 * 获取已安装的组件列表
 */
-(NSArray *)getInstalledBundles;


/**
 * 根据identifier获取组件
 */
-(LDFBundle *)getBundle:(NSString *)bundleIdentifier;


/**
 * 指定ipa路径初始化一个组件
 */
-(BOOL) installBundleWithIpaPath:(NSString *)ipaPath;


/**
 * 根据BundleName卸载一个组件
 */
-(BOOL)unInstallBundle:(NSString *)bundleIdentifier;


/**
 * 根据BundleName查看Bundle是否安装
 */
-(BOOL)isBundleInstalled:(NSString *)bundleIdentifier;


/**
 * 根据bundle信息, 从服务器更新远程的Bundle
 * 下载完成之后自动重新加载该组件
 */
-(BOOL)installRemoteBundlePackage:(LDFBundle *)bundle listener:(id<LDFBundleManagerDownloadListener>)containerDownloadListener;




@end
