//
//  LDFBundleContainer.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const STATUS_SCUCCESS;
extern int const STATUS_ERR_DOWNLOAD;
extern int const STATUS_ERR_INSTALL;
extern int const STATUS_ERR_CANCEL;
extern NSString* const NOTIFICATION_BOOT_COMPLETED;

@protocol LDFBundleContainerListener <NSObject>
-(void) onFinish:(int) statusCode;
@end


/**
 * @class 管理整个应用的组件检查、下载、安装和启动
 * 控制一个单例
 */
@protocol LDBundleDownloadListener;
@class LDFBundle;
@interface LDFBundleContainer : NSObject {
    
}

+(instancetype)sharedContainer;

/**
 * 启动bundle容器
 */
-(void)bootBundleContainerWithListener:(id<LDFBundleContainerListener>) listener;


/**
 * 判断bundle容器是否启动完毕
 */
-(BOOL)isContainerBootCompleted;


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
-(LDFBundle *)getBundleWithName:(NSString *)bundleName;


/**
 * 指定ipa路径初始化一个组件
 */
-(BOOL)installBundleWithIpaPath:(NSString *)ipaPath toDestPath:(NSString *)destPath;


/**
 * 根据BundleName卸载一个组件
 */
-(BOOL)unInstallBundleWithName:(NSString *)bundleName;


/**
 * 根据BundleName查看Bundle是否安装
 */
-(BOOL)isBundleInstalled:(NSString *)bundleName;


@end
