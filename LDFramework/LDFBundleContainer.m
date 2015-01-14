//
//  LDFBundleContainer.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFBundleContainer.h"

#import "LDFDebug.h"
#import "LDFCommonDef.h"
#import "LDFFileManager.h"
#import "LDFNetUtils.h"

#import "LDFBundle.h"
#import "LDFBundleUpdator.h"
#import "LDFBundleDownloader.h"
#import "LDFBundleInstaller.h"


#define CRC32_BUNDLE_INSTALLED @"LDF_Installed_Bundles_CRC32_Values"


NSString * const NOTIFICATION_BUNDLE_INSTALLED = @"com.lede.LDFramework.NOTIFICATION_BUNDLE_INSTALLED";
NSString * const NOTIFICATION_BUNDLE_UNINSTALLED = @"com.lede.LDFramework.NOTIFICATION_BUNDLE_UNINSTALLED";
NSString * const NOTIFICATION_BOOT_COMPLETED = @"com.lede.LDFramework.NOTIFICATION_BOOT_COMPLETED";


@interface LDFBundleContainer ()<LDFBundleDownloadListener, LDFBundleUpdatorListener>{
    NSMutableDictionary *_remoteBundles; //远程组件列表
    NSMutableDictionary *_installedBundles; //已解压安装组件列表
    
    NSMutableDictionary *_loadingBundles; //正在下载更新的组件列表
    NSMutableDictionary *_bundleCRC32s; //纪录第一次安装组件时解压文件的CRC值
    NSMutableDictionary *_exportedService; //所有组件对外开放的服务列表
    
    NSString *_signature; //主程序的签名
    
    LDFBundleInstaller *_installer;
    id<LDFBundleContainerListener> _listener;
    
    BOOL _initializing;
    BOOL _bootCompleted;
    BOOL _needReboot;
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
        _remoteBundles = [[NSMutableDictionary alloc] initWithCapacity:2];
        _installedBundles = [[NSMutableDictionary alloc] initWithCapacity:2];
        _loadingBundles = [[NSMutableDictionary alloc] initWithCapacity:2];
        _exportedService = [[NSMutableDictionary alloc] initWithCapacity:2];
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
#warning fixme ios如何从MainBundle获取签名信息（字符串）
    _signature = @"";
    
    //把安装组件的CRC值存储，防止安装文件被更改
    _bundleCRC32s = [[NSUserDefaults standardUserDefaults] objectForKey:CRC32_BUNDLE_INSTALLED];
    if(_bundleCRC32s == nil){
        _bundleCRC32s = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    
    //维持一个安装器
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


#pragma mark - install local bundles
/**
 * 检查本地的Bundle(包括随主APP一起发布，也包括通过插件更新新安装的)是否安装，否则安装
 */
-(void)installLocalBundles{
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *srcFiles = [[NSBundle mainBundle] pathsForResourcesOfType:BUNDLE_EXTENSION inDirectory:LOCAL_BUNDLES_DIR];
        if(srcFiles && srcFiles.count > 0) {
            LOG(@"install bundles located in main bundle");
            NSString *toInstallDir = [LDFFileManager bundleCacheDir];
            for(NSString *srcFilePath in srcFiles){
                //检查本地版本是否有效和是否需要安装
                NSString *bundleFileName = [srcFilePath lastPathComponent];
                NSDictionary *properties = [LDFFileManager getPropertiesFromLocalBundleFile:srcFilePath];
                NSString *bundleIdentifier = [properties objectForKey:BUNDLE_PACKAGENAME];
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
                    success = [fileManager copyItemAtPath:srcFilePath toPath:ipaInstalledFilePath error:&error];
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
    @catch (NSException *exception) {
    }
    @finally {
    }
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
 * 指定ipa路径初始化一个组件
 */
-(BOOL) installBundleWithIpaPath:(NSString *)ipaPath {
    //不是更新
    return [self installBundleWithIpaPath:ipaPath update:NO];
}


-(BOOL)installBundleWithIpaPath:(NSString *)ipaPath update:(BOOL)update{
    LDFBundle *bundle = [_installer installBundleWithPath:ipaPath];
    if(bundle != nil){
        [_installedBundles setObject:bundle forKey:[bundle identifier]];
        [self updateBundleState:INSTALLED forBundle:bundle.identifier];
        
        if([bundle autoStartup]){
            //告知bundle提供的服务
            [self addExportedService:bundle];
            
            //如果是更新组件，需要卸载原有的组件，再加在进去；
            if(update){
                if([bundle stop]){
                    [bundle start];
                }
            }
            
            else {
                [bundle start];
            }
        }
        
        LOG(@"install bundle: %@ success", bundle.name);
    }
    
    return bundle != nil;
}


#pragma mark - load installed bundles
/**
 * 校验本地安装的dynamic framework是否有效，防止被更改替换
 * 对于dynamic framework的配置文件也要进行检验
 * 如果有效，加载组件的配置信息
 */
-(void)verifyInstalledBundles{
    NSString *bundleCache = [LDFFileManager bundleCacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *listFiles = [fileManager contentsOfDirectoryAtPath:bundleCache error:nil];
    if(listFiles && listFiles.count > 0){
        for(NSString *fileName in listFiles){
            NSString *filepath = [bundleCache stringByAppendingPathComponent:fileName];
            NSDictionary *fileAtrrDic = [fileManager attributesOfItemAtPath:filepath error:nil];
            if(fileAtrrDic){
                //如果不是文件夹
                if(![[fileAtrrDic fileType] isEqualToString:NSFileTypeDirectory]){
                    long crc32 = [LDFFileManager getCRC32: filepath];
                    NSDictionary *properties = [LDFFileManager getPropertiesFromLocalBundleFile:filepath];
                    NSString *bundleIdentifier = [properties objectForKey:BUNDLE_PACKAGENAME];
                    long install_crc32 = [_bundleCRC32s objectForKey:bundleIdentifier]?[[_bundleCRC32s objectForKey:bundleIdentifier] longValue] : 0;
                    if(crc32 != install_crc32){
                        [_bundleCRC32s removeObjectForKey:bundleIdentifier];
                        [self reStoreBundleCRC32s];
                    }
                }
                
                else{
                    //读取framework属性
                    LDFBundle *bundle = [[LDFBundle alloc] initBundleWithPath:filepath];
                    if(!bundle.infoDictionary ||  bundle.infoDictionary.allKeys.count == 0){
                        continue;
                    }
                    
                    //如果ipa被删除，忽略改bundle的安装文件夹, 并删除
                    NSString *ipaPath = [bundleCache stringByAppendingFormat:@"/%@%@", [[filepath lastPathComponent] stringByDeletingPathExtension], BUNDLE_EXTENSION];
                    if(![fileManager fileExistsAtPath:ipaPath]){
                        [_bundleCRC32s removeObjectForKey:bundle.identifier];
                        [self reStoreBundleCRC32s];
                        [fileManager removeItemAtPath:filepath error:nil];
                        continue;
                    }
                    
                    bundle.state = INSTALLED;
                    [_installedBundles setObject:bundle forKey:bundle.identifier];
                    
                    //纪录服务提供
                    [self addExportedService:bundle];
                }
            }//if file attr
        }//for
    }//if files exists
}


/**
 * 根据配置信息，加载配置为自动启动的组件
 * static framework默认为自启动Bundle
 */
-(void)loadAutoStartBundles{
    NSArray *keys = _installedBundles.allKeys;
    if(keys && keys.count > 0){
        for(NSString *key in keys){
            LDFBundle *bundle = [_installedBundles objectForKey:key];
            [self startBundle:bundle];
        }
    }//if
}


/**
 * 加载Bundle
 */
-(void)startBundle:(LDFBundle *)bundle{
    if(bundle != nil && [bundle autoStartup]
       && (bundle.state & STARTED) == 0){
        bundle.state |= STARTED;
        NSString *importServiceStr = [bundle importServices];
        if(importServiceStr && ![importServiceStr isEqualToString:@""]){
            NSArray *importServices = [importServiceStr componentsSeparatedByString:@","];
            for(NSString *service in importServices){
                LDFBundle *linkBundle = [_exportedService objectForKey:service];
                [self startBundle:linkBundle];
            }
        }//if
        
        //启动完依赖服务之后，加载该Bundle
        [bundle start];
        LOG(@"bundle loaded: %@", bundle.name);
    }
}


/**
 * 根据bundle的配置返回是否能够自动安装
 * 当前配置为任意下载，或者当前为wifi且配置只允许wifi下载
 */
-(BOOL)autoInstall:(LDFBundle *) bundle {
    LOG(@"install_level = %d", bundle.autoInstallLevel);
    return [bundle autoInstallLevel] == INSTALL_LEVEL_ALL
    || ([[LDFNetUtils sharedNetMoniter] isWifi] && bundle.autoInstallLevel == INSTALL_LEVEL_WIFI);
}



#pragma mark - refresh remote bundleInfo
-(void)refreshRemoteBundleInfo:(NSString *)url {
    LOG(@"start refresh remoteBundleInfo");
    [LDFBundleUpdator refreshRemoteBundleInfoWithURL:url delegate:self];
}

-(void)updatorOnSuccess:(NSArray *)bundleInfoArray {
    [self parseRemoteBundle:bundleInfoArray];
}

-(void)updatorOnFailure{
    LOG(@"remote desc error");
}


-(void)parseRemoteBundle:(NSArray *)array {
    if(array && array.count > 0){
        [_remoteBundles removeAllObjects];
        for(int i = 0; i < array.count; i++){
            LDFBundle *bundle = nil;
            @try {
                NSDictionary *bundleInfo = [array objectAtIndex:i];
                NSString *minVer = [bundleInfo objectForKey:@"Framework-Version"];
                if(!minVer || [minVer isEqualToString:@""]){
                    minVer = @"0";
                }
                if(versionCompare(minVer, CUR_FRAMEWORK_VERSION) > 0){
                    LOG(@"current framework is too old for this bundle");
                    continue;
                }
                
                NSString *minHostVer = [bundleInfo objectForKey:@"Host-Version"];
                if(!minHostVer || [minHostVer isEqualToString:@""]){
                    minHostVer = @"0";
                }
                
                if(versionCompare(minHostVer, CUR_HOST_VERSION)){
                    LOG(@"hostApp version is too low for this bundle");
                    continue;
                }
                
                NSString *remoteBundleIdentifier = [bundleInfo objectForKey:@"Bundle-PackageName"];
                LDFBundle *bundle = nil;
                if([_installedBundles objectForKey:remoteBundleIdentifier]){
                    LDFBundle *bundle0 = [_installedBundles objectForKey:remoteBundleIdentifier];
                    NSString *remoteBundleVersion = [bundleInfo objectForKey:@"Bundle-Version"];
                    if(remoteBundleVersion && [remoteBundleVersion isEqualToString:@""] &&
                       versionCompare(bundle0.version, remoteBundleVersion) > 0){
                        bundle0.state |= HAS_NEWVERSION;
                        bundle = bundle0;
                        [self updateRemoteBundlePackage:bundle0 listener:self update:YES];
                    }
                }
                
                //如果是一个新的组件安装
                if(bundle == nil){
                    
                }
                
                
                
                
                
                [_remoteBundles setObject:bundleInfo forKey:remoteBundleIdentifier];
                /**
                 * 在wifi环境下，如果为自启动组件，且依赖服务已经启动，则自启动该远程插件
                 */
                BOOL remoteAutoStart = [[bundleInfo objectForKey:BUNDLE_AUTO_STARTUP] boolValue];
                
                /*
                 "Bundle-Name":"framework",
                 "Bundle-PackageName":"framework",
                 "Bundle-UpdateUrl":"http://pimg1.126.net/swdp/plugin_test/core_release.jar",
                 "Bundle-Version":"1.3.0",
                 "Bundle-VersionCode":5,
                 "Bundle-Size":30000,
                 "Bundle-InstallLevel":0,
                 "Framework-Version":3
                 */
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
    }
}



#pragma mark -  update remote bundle
/**
 * 根据bundle信息, 从服务器更新远程的Bundle
 * 下载完成之后自动重新加载该组件
 */
-(BOOL)installRemoteBundlePackage:(LDFBundle *)bundle listener:(id<LDFBundleContainerDownloadListener>) containerDownloadListener{
    return [self updateRemoteBundlePackage:bundle listener:containerDownloadListener update:NO];
}


-(BOOL)updateRemoteBundlePackage:(LDFBundle *)bundle listener:(id<LDFBundleContainerDownloadListener>) listener update:(BOOL)update{
    NSString *bundleKey = bundle.identifier;
    NSString *lastContainerDownloadListenerHash = [_loadingBundles objectForKey:bundleKey];
    bundle.state |= INSTALLING;
    if(lastContainerDownloadListenerHash && ![lastContainerDownloadListenerHash isEqualToString:@""]){
        LOG(@"the same bundle is loading: %@", bundleKey);
        return NO;
    }
    
    [_loadingBundles setObject:listener forKey:bundleKey];
    if([LDFBundleDownloader updateRemoteBundlePackage:bundle delegate:self]){
        return YES;
    } else {
        [_loadingBundles removeObjectForKey:bundleKey];
        return NO;
    }
}

/**
 * 下载器下载完毕
 */
-(void) downloaderOnFinish:(long long)statusCode withBundle:(LDFBundle *)bundle{
    id<LDFBundleContainerDownloadListener> containListener = [_loadingBundles objectForKey:bundle.identifier];

    if(statusCode <= 0){
        LOG(@"download error:%@", bundle.updateURL);
        bundle.state &= (~INSTALLING);
        [_loadingBundles removeObjectForKey:bundle.identifier];
        
        statusCode = STATUS_ERR_DOWNLOAD;
    } else {
        LOG(@"download success:%@", bundle.updateURL);
        
#warning fixme 开启新线程处理安装
        //成功之后的处理, 开启新线程
        [self unInstallBundle:bundle.identifier];
        
        //拷贝刚刚下载成功的ipa文件
        NSString *filePath = [[LDFFileManager bundleCacheDir] stringByAppendingFormat:@"/%@%@", bundle.name, BUNDLE_EXTENSION];
        NSString *newFilePath = [[LDFFileManager bundleCacheDir] stringByAppendingFormat:@"/%@_new%@", bundle.name, BUNDLE_EXTENSION];
        if(![LDFFileManager renameNewDownloadFileWithName: bundle.name]){
            statusCode = STATUS_ERR_INSTALL;
            bundle.state &= (~INSTALLING);
            LOG(@"install bundle %@ error", bundle.name);
        } else {
            
#warning fixme
            //update not known
            BOOL r = NO;
            r = [self installBundleWithIpaPath:filePath update:YES];
            if(r){
                bundle.state  &= (~INSTALLING);
                LOG(@"install bundle %@ success", bundle.name);
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BUNDLE_INSTALLED object:nil];
                if(_listener && [_listener respondsToSelector:@selector(onFinish:)]){
                    [_listener onFinish:STATUS_SCUCCESS];
                }

            }
        }
        
        //为保险起见，删除下载重命名的文件
        [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:nil];
    }
    
    if(containListener && [containListener respondsToSelector:@selector(containerDownloadOnFinish:)]){
        [containListener containerDownloadOnFinish:statusCode];
    }

    //结束通知完毕，去除保存的containListener
    [_loadingBundles removeObjectForKey:bundle.identifier];
}


/**
 * 下载器进度监控器
 */
-(void) downloaderOnProgress:(long long)written total:(long long)total withBundle:(LDFBundle *)bundle{
    if([_loadingBundles objectForKey:bundle.identifier]){
        id<LDFBundleContainerDownloadListener> containListener = [_loadingBundles objectForKey:bundle.identifier];
        if(containListener && [containListener respondsToSelector:@selector(containerDownloadOnProgress:total:)]){
            [containListener containerDownloadOnProgress:written total:total];
        }
    }
}



#pragma mark - common method
/**
 * 判断bundle容器是否启动完毕
 */
-(BOOL)isContainerBootCompleted{
    return _bootCompleted;
}


/**
 * 获取本地和服务器端的所有可安装组件列表
 */
-(NSArray *)getAllBundles{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:2];
    if(_remoteBundles && _remoteBundles.allKeys.count > 0){
        [temp addObjectsFromArray:[_remoteBundles objectsForKeys:_remoteBundles.allKeys notFoundMarker:nil]];
    }
    
    NSArray *installedKeys = _installedBundles.allKeys;
    for(NSString *key in installedKeys){
        if(![_remoteBundles objectForKey:key]){
            [temp addObject:[_installedBundles objectForKey:key]];
        }
    }
    
    return (NSArray *)temp;
}


/**
 * 获取远端服务器可安装的组件列表
 */
-(NSArray *)getRemoteBundles{
    return [_remoteBundles objectsForKeys:_remoteBundles.allKeys notFoundMarker:nil];
}


/**
 * 获取已安装的组件列表
 */
-(NSArray *)getInstalledBundles{
    return [_installedBundles objectsForKeys:_installedBundles.allKeys notFoundMarker:nil];
}


/**
 * 根据identifier获取组件
 */
-(LDFBundle *)getBundle:(NSString *)bundleIdentifier{
    LDFBundle *bundle1 = [_remoteBundles objectForKey:bundleIdentifier];
    if(bundle1 != nil){
        return bundle1;
    } else {
        return [_installedBundles objectForKey:bundleIdentifier];
    }
}


/**
 * 根据BundleName卸载一个组件
 */
-(BOOL)unInstallBundle:(NSString *)bundleIdentifier{
    LDFBundle *bundle = [_installedBundles objectForKey:bundleIdentifier];
    if(bundle != nil && [bundle isLoaded]){
        [bundle stop];
    }
    
    //卸载bundle
    BOOL result = [_installer uninstallBundle:bundle.name];
    if(result){
        [self updateBundleState:UNINSTALLED forBundle:bundle.identifier];
        [_installedBundles removeObjectForKey:bundle.identifier];
        
#warning fixme
        //广播插件卸载完成
    }
    
    return result;
}


/**
 * 根据BundleName查看Bundle是否安装
 */
-(BOOL)isBundleInstalled:(NSString *)bundleIdentifier{
    return [_installedBundles objectForKey:bundleIdentifier] != nil;
}


/**
 * 返回是否需要重启
 */
-(BOOL) isNeedReboot {
    return _needReboot;
}



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
        [self reStoreBundleCRC32s];
    }
}

/**
 * 持久化安装组件的CRC32值
 */
-(void)reStoreBundleCRC32s {
    if(_bundleCRC32s){
        [[NSUserDefaults standardUserDefaults] setObject:_bundleCRC32s forKey:CRC32_BUNDLE_INSTALLED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/**
 * 向框架中注册bundle支持的服务
 * 每个服务名称和对应的实例化Bundle配置
 */
-(void)addExportedService:(LDFBundle *)bundle {
    NSString *services_String = bundle.exportServices;
    if(services_String && ![services_String isEqualToString:@""]){
        NSArray *services_Array = [services_String componentsSeparatedByString:@","];
        for(NSString *service in services_Array){
            [_exportedService setObject:bundle forKey:service];
        }
    }
}


/**
 * 检查bundle依赖的服务,如果依赖服务没有开启，则不能自动安装和启动
 */
-(BOOL)checkImportService:(LDFBundle *)bundle {
    NSString *services_String = bundle.importServices;
    if(services_String && ![services_String isEqualToString:@""]){
        NSArray *services_Array = [services_String componentsSeparatedByString:@","];
        for(NSString *service in services_Array){
            LDFBundle *linkBundle = (LDFBundle *)[_exportedService objectForKey:service];
            if(linkBundle == nil){
                return  NO;
            }
        }//for
    }//if
    
    return YES;
}








@end
