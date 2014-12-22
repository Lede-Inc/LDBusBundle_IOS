//
//  LDBundleBusCenter.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDBusCenter.h"

#import "LDBundle.h"
#import "LDUIBusCenter.h"
#import "LDServiceBusCenter.h"
#import "LDMessageBusCenter.h"

#import "LDNavigator.h"
#import "TTGlobalNavigatorMetrics.h"


static LDBusCenter* busCenter = nil;

@interface LDBusCenter () {
    LDNavigator *_mainNavigator;
}

@property (nonatomic, retain) NSString *bundleCacheDir;
@property (nonatomic, assign) LDUIBusCenter *uibusCenter;
@property (nonatomic, assign) LDServiceBusCenter *servicebusCenter;
@property (nonatomic, assign) LDMessageBusCenter *messagebusCenter;

@end


@implementation LDBusCenter
@synthesize bundlesMap = _bundlesMap;
@dynamic bundleCacheDir;
@dynamic uibusCenter, servicebusCenter, messagebusCenter;


+ (LDBusCenter*) busCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        busCenter = [[self alloc] init];
    });
    return busCenter;
}

-(id)init {
    self = [super init];
    if(self) {
        //全局初始化一个navigator
        _mainNavigator = [LDNavigator navigator];
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        if(!rootWindow){
            rootWindow = [[UIWindow alloc] initWithFrame:TTScreenBounds()];
        }
        
        _mainNavigator.window = rootWindow;
        _bundlesMap = [[NSMutableDictionary alloc] initWithCapacity:5];
            
    }
    
    return self;
}


-(LDUIBusCenter *) uibusCenter {
    return [LDUIBusCenter uibusCenter];
}

-(LDServiceBusCenter *) servicebusCenter {
    return [LDServiceBusCenter servicebusCenter];
}

-(LDMessageBusCenter *) messagebusCenter {
    return [LDMessageBusCenter messagebusCenter];
}

/**
 * bus center preload config
 */
-(void) preloadConfig{
    //程序启动时，将main bundle中自己携带的static framework配置文件拷贝到cache目录中
    //以后从线上动态下载的static framework配置文件和dynamic framework均下载到该目录
    if([self copyConfigBundleToLibraryCache]){
        [self loadAllLocalBundleConfig];
    }
}

/**
 * 对于保证整个app统一scheme导航的初始化
 */
-(void) preloadConfigWithScheme:(NSString *)scheme{
    if([self setNavigatorMainScheme:scheme]){
        [self preloadConfig];
    }
}


/**
 * 设置当前navigator的rootViewController
 */
-(BOOL) setNavigatorRootViewController:(UIViewController *)theRoot{
    BOOL success = NO;
    if(theRoot && _mainNavigator && _mainNavigator.window){
        _mainNavigator.rootViewController = theRoot;
        success = YES;
    }
    return success;
}

/**
 * 请在preloadConfig之前设置整个应用的的scheme
 * 如果设置，应用内所有bundle的URL Pattern的scheme将通过设置scheme统一导航
 * 如果不设置，所有的UI总线的URL Pattern的scheme将以bundle name设置；
 */
-(BOOL) setNavigatorMainScheme:(NSString *)theMainScheme;{
    BOOL success = NO;
    if(theMainScheme && ![theMainScheme isEqualToString:@""]){
        _mainScheme = theMainScheme;
        success = YES;
    }
    
    return success;
}




/**
 * 拷贝mainbundle 所有static bundle的配置文件到cache目录
 * @return 检查拷贝完成返回YES
 */
-(BOOL) copyConfigBundleToLibraryCache {
    NSString *bundleCacheDir = self.bundleCacheDir;
    if( bundleCacheDir == nil || [bundleCacheDir isEqualToString:@""]) return NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *bundlePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle" inDirectory:nil];
    for(int i =0; i<bundlePaths.count; i++){
        NSString *fromPath = [bundlePaths objectAtIndex:i];
        NSString  *configFromPath = [fromPath stringByAppendingPathComponent:@"busconfig.xml"];
        if([fileManager fileExistsAtPath:configFromPath]){
            NSString *toPath = [bundleCacheDir stringByAppendingPathComponent:[fromPath lastPathComponent]];
            NSLog(@"toBundleCacheDir>>>>%@", toPath);
            //如果存在，在debug环境中先删除，再拷贝; 如果在release环境，不删除已存在Cache的bundle
            NSError *error;
            if([fileManager fileExistsAtPath:toPath]){
#ifdef DEBUG
                [fileManager removeItemAtPath:toPath error:&error];
                if(error){
                    NSLog(@"remove bundle error:%@", [error localizedDescription]);
                }
#endif
            }
            
            //然后在做一次判断，如果不存在或者debug已删除，拷贝bundle文件；
            if(![fileManager fileExistsAtPath:toPath]){
                [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
                if(error){
                    NSLog(@"copy bundle error:%@", [error localizedDescription]);
                }
            }
        }//if exist
    }//for bundlePaths
    return YES;
}


/**
 * 从bundleCache 目录加载所有的bundle配置文件
 * @return 检查拷贝完成返回YES
 *
 */
-(BOOL) loadAllLocalBundleConfig {
    NSString *bundleCacheDir = self.bundleCacheDir;
    if(bundleCacheDir==nil || [bundleCacheDir isEqualToString:@""]) return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:bundleCacheDir error:nil];
    if(fileArray && fileArray.count > 0) {
        for(NSString *filename in fileArray){
            if([filename hasSuffix:@".bundle"] || [filename hasSuffix:@".framework"]){
                NSString *bundleFilePath = [bundleCacheDir stringByAppendingPathComponent:filename];
                LDBundle *bundle = [[LDBundle alloc] initBundleWithPath: bundleFilePath];
                if(bundle != nil){
                    NSString *bundleUUID = (bundle.bundleIdentifier && ![bundle.bundleIdentifier isEqualToString:@""]) ? bundle.bundleIdentifier:[filename stringByDeletingPathExtension];
                    NSString *key = [NSString stringWithFormat:@"_bundle_%@_", bundleUUID];
                    [_bundlesMap setObject:bundle forKey:key];
                    //设置每个bundle的全局导航器
                    [bundle setBundleNavigator:_mainNavigator];
                    
                    //先设置bundleScheme，
                    //再初始化每个bundle对应的UIBusConnector，并给connetor设置导航map
                    if(_mainScheme && ![_mainScheme isEqualToString:@""]){
                        [bundle setBundleScheme:_mainScheme];
                    }
                    [bundle setUIBusConnectorToBundle];

                    //将bundle中服务注册到服务总线中去；
                    NSLog(@"bundleIdentier>>>>%@", bundle.bundleIdentifier);
                    [self.servicebusCenter registerServiceToBusBatchly:[bundle getServiceMapFromConfigObj]];
                    
                    //将bundle中配置的消息注册到消息总线中
                    [self.messagebusCenter registerMessageToBusBatchly:[bundle getMessageMapFromConfigObj]];
                }//if bundle
            }//if filename
        }//for filearray
    }//if count
    
    return YES;
}


/**
 * 获取Bundle存储的目录
 * @return bundle存储目录
 */
-(NSString *) bundleCacheDir {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundleCacheDir = [cacheDir stringByAppendingPathComponent:@"_bundleCache_"];
    NSLog(@"bundleCacheDir>>>>%@", bundleCacheDir);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:bundleCacheDir]){
        BOOL isCreate = [fileManager createDirectoryAtPath:bundleCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        //bundle cache 目录建立不成功，返回不进行拷贝
        if(!isCreate) {
            return @"";
        }
    }
    
    return bundleCacheDir;
}



@end
