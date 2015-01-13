//
//  LDFBundleContainer.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFBundleContainer.h"

#import "LDFDebug.h"
#import "LDFBundleUpdator.h"
#import "LDFBundleDownloader.h"
#import "LDFBundleInstaller.h"

#import "LDFBundle.h"
#import "LDFFileManager.h"
#import "LDFCommonDef.h"


#define CRC32_BUNDLE_INSTALLED @"LDF_Installed_Bundles_CRC32_Values"

int const STATUS_SCUCCESS = 1;
int const STATUS_ERR_DOWNLOAD = -1;
int const STATUS_ERR_INSTALL = -2;
int const STATUS_ERR_CANCEL = -3;
NSString* const NOTIFICATION_BOOT_COMPLETED = @"LDBundleContainer_BootCompleted";



@interface LDFBundleContainer (){
    NSMutableDictionary *_remoteBundles; //远程组件列表
    NSMutableDictionary *_installedBundles; //已解压安装组件列表
    NSMutableDictionary *_loadingBundles; //已加载到内存的组件列表
    
    NSMutableDictionary *_bundleCRC32s;
    NSMutableDictionary *_exportedService; //组件对外开放的服务列表
    NSString *_signature;
    BOOL _initializing;
    id<LDFBundleContainerListener> _listener;
    BOOL _bootCompleted;
    
    LDFBundleInstaller *_installer;
}

@end


@implementation LDFBundleContainer

+ (instancetype)sharedContainer{
    static LDFBundleContainer *bundleContainer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleContainer = [[LDFBundleContainer alloc] init];
    });
    return bundleContainer;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


/**
 * 启动bundle容器
 */
-(void)bootBundleContainerWithListener:(id<LDFBundleContainerListener>) listener{
    if(_initializing){
        return;
    }
    
    _initializing = YES;
    _listener = listener;
#warning fixme _signature
    _signature = @"";
    
    _bundleCRC32s = [[NSUserDefaults standardUserDefaults] objectForKey:CRC32_BUNDLE_INSTALLED];
    if(_bundleCRC32s == nil){
        _bundleCRC32s = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    _installer = [[LDFBundleInstaller alloc] init];
    _installer.signature = _signature;
    
    //开启一个线程去启动BundleContainer
    [NSThread detachNewThreadSelector:@selector(backThreadToBootBundleContainer) toTarget:self withObject:nil];
}


//后台线程完成Container的启动
-(void)backThreadToBootBundleContainer {
    [self installLocalBundles];
    
    [self verifyInstalledBundles];
    
    [self loadAutoStartBundles];
    
    //启动完成发送消息
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BOOT_COMPLETED object:nil];
    if(_listener && [_listener respondsToSelector:@selector(onFinish:)]){
        [_listener onFinish:STATUS_SCUCCESS];
    }
    
    _bootCompleted = YES;
}


/**
 * 检查本地的Bundle(包括随主APP一起发布，也包括通过插件更新新安装的)是否安装，否则安装
 */
-(void)installLocalBundles{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *localBundlePaths = [mainBundle pathsForResourcesOfType:@".ipa" inDirectory:@"bundles"];
    NSString *toInstallDir = [LDFFileManager bundleCacheDir];
    if(localBundlePaths && localBundlePaths.count > 0) {
        LOG(@"install bundles located in main bundle");
        //遍历ipa列表拷贝需要拷贝到bundlecache的文件
        for(NSString *filePath in localBundlePaths){
            //获取bundle中的info.plist的属性
            //bundle签名 @"CFBundleSignature"
            //最低支持版本 @"MinimumOSVersion"
            //bundle类型 @"CFBundlePackageType"
            //bundle版本号 @"CFBundleShortVersionString"
            //bundle build版本号 @"CFBundleVersion"
            //版本名字 @"CFBundleName"
            
            //检查本地版本是否有效和是否需要安装
            NSString *bundleFileName = [filePath lastPathComponent];
            NSDictionary *properties = [LDFFileManager getPropertiesFromLocalBundleFile:filePath];
            NSString *bundleIdentifier = [properties objectForKey:@"CFBundleIdentifier"];
            if([bundleIdentifier isEqualToString:@""]){
                continue;
            }
            
            //如果ipa未拷贝，如果ipa未解压安装，如果ipa版本有更新
            NSString *ipaInstalledFilePath = [toInstallDir stringByAppendingPathComponent:bundleFileName];
            NSString *ipaInstalledDir = [toInstallDir stringByAppendingFormat:@"/%@.framework", [bundleFileName stringByDeletingPathExtension]];
            if(![fileManager fileExistsAtPath:ipaInstalledFilePath] ||
               ![fileManager fileExistsAtPath:ipaInstalledDir] ||
               [self needUpdateLocalBundle:properties installFolder:toInstallDir bundleFileName:bundleFileName]){
                NSError *error = nil;
                //如果ipa已拷贝，但是未安装，或者需要更新，直接先删除
                if([fileManager fileExistsAtPath:ipaInstalledFilePath]){
                    [fileManager removeItemAtPath:ipaInstalledFilePath error:&error];
                    if(error){
                        LOG(@"delete exists ipa file failure!!");
                    }
                }
                
                BOOL success;
                //从mainBundle中拷贝最新版本的ipa
                success = [fileManager copyItemAtPath:filePath toPath:ipaInstalledFilePath error:&error];
                if(!success){
                    NSLog(@"error>>>>>%@", error);
                }
                
                //拷贝成功安装组件, 解压IPA
                if(success){
                    [self installBundleWithIpaPath:ipaInstalledFilePath];
                }
            }//if
        }//for
    }//if
}





/**
 * 对比本地携带bundle版本是否高于已安装的版本
 * 条件：本地已安装版本
 */
-(BOOL)needUpdateLocalBundle:(NSDictionary *)properties1
               installFolder:(NSString *)toInstallBundleDir
              bundleFileName:(NSString *)fileName{
    //如果当前组件的依赖框架版本大于当前版本，不升级；
    NSString *minFrameworkVerStr = [properties1 objectForKey:MIN_FRAMEWORK_VERSION];
    if(!minFrameworkVerStr|| [minFrameworkVerStr isEqualToString:@""]){
        minFrameworkVerStr = @"0";
    }
    if(versionCompare(minFrameworkVerStr, CUR_FRAMEWORK_VERSION) > 0){
        LOG(@"Current framework version is too low %@", CUR_FRAMEWORK_VERSION);
        return NO;
    }
    
    //如果当前组件的依赖主程序版本大于当前主程序版本，不升级；
    NSString *minHostVerStr = [properties1 objectForKey:MIN_HOST_VERSION];
    if(!minHostVerStr || [minHostVerStr isEqualToString:@""]){
        minHostVerStr = @"0";
    }
    
    if(versionCompare(minHostVerStr, CUR_HOST_VERSION) > 0){
        LOG(@"Current hostApp Version is too low: %@", CUR_HOST_VERSION);
        return NO;
    }
    
    //如果框架和主程序满足条件，比较安装目录版本和当前主程序bundle中的版本
    NSString *installedBundlePath = [toInstallBundleDir stringByAppendingPathComponent:fileName];
    NSString *v1 = [properties1 objectForKey:BUNDLE_VERSION];
    NSDictionary *properties0 = [LDFFileManager getPropertiesFromLocalBundleFile:installedBundlePath];
    NSString *v0 = [properties0 objectForKey:BUNDLE_VERSION];
    if(versionCompare(v1, v0) > 0){
        return YES;
    }
    
    return NO;
}



/**
 * 校验本地安装的dynamic framework是否有效，防止被更改替换
 * 对于dynamic framework的配置文件也要进行检验
 * 如果有效，加载组件的配置信息
 */
-(void)verifyInstalledBundles{
    
}


/**
 * 根据配置信息，加载配置为自动启动的组件
 * static framework默认为自启动Bundle
 */
-(void)loadAutoStartBundles{
    
}


/**
 * 判断bundle容器是否启动完毕
 */
-(BOOL)isContainerBootCompleted{
    
    return YES;
}


/**
 * 获取本地和服务器端的所有可安装组件列表
 */
-(NSArray *)getAllBundles{
    
    return nil;
}


/**
 * 获取远端服务器可安装的组件列表
 */
-(NSArray *)getRemoteBundles{
    return nil;
}

/**
 * 获取已安装的组件列表
 */
-(NSArray *)getInstalledBundles{
    return nil;
}


/**
 * 根据identifier获取组件
 */
-(LDFBundle *)getBundleWithName:(NSString *)bundleName{
    return nil;
}


/**
 * 指定ipa路径初始化一个组件
 */
-(BOOL)installBundleWithIpaPath:(NSString *)ipaPath{
    LDFBundle *bundle = [_installer installBundleWithPath:ipaPath];
    if(bundle != nil){
        [_installedBundles setObject:bundle forKey:[bundle identifier]];
        [self updateBundleState:INSTALLED forBundle:bundle.identifier];
        
        if([bundle autoStartup]){
            //告知bundle提供的服务
            
        }
    }
    
    return YES;
}


/**
 * 根据BundleName卸载一个组件
 */
-(BOOL)unInstallBundleWithName:(NSString *)bundleName{
    return NO;
}


/**
 * 根据BundleName查看Bundle是否安装
 */
-(BOOL)isBundleInstalled:(NSString *)bundleName{
    return NO;
}



#pragma mark common method
/**
 * 更新bundle的状态
 */
-(void)updateBundleState:(int)state forBundle:(NSString *)bundleIdentifier {
    LDFBundle *bundle = [_installedBundles objectForKey:bundleIdentifier];
    LDFBundle *bundle2 = [_remoteBundles objectForKey:bundleIdentifier];
    
    if(bundle != nil){
        if(state == INSTALLED){
            [_bundleCRC32s setObject:[NSNumber numberWithLong:bundle.crc32] forKey:bundleIdentifier];
            bundle.state = INSTALLED;
            if(bundle2 != nil){
                bundle2.state = INSTALLED;
            }
        }
        
        else if(state == UNINSTALLED){
            [_bundleCRC32s removeObjectForKey:bundleIdentifier];
            bundle.state = UNINSTALLED;
            if(bundle2 != nil){
                bundle2.state = UNINSTALLED;
            }
        }
        
        //每次保存一下
        [[NSUserDefaults standardUserDefaults] setObject:_bundleCRC32s forKey:CRC32_BUNDLE_INSTALLED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
