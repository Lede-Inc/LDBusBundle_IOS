//
//  LDFBundleInstaller.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFDebug.h"
#import "LDFBundleInstaller.h"
#import "LDFFileManager.h"
#import "LDFBundle.h"
#import "LDFCommonDef.h"

@interface LDFBundleInstaller () {
    NSArray *_myAppArchiteture;
}

@end



@implementation LDFBundleInstaller
@synthesize signature;


-(id) init {
    self = [super init];
    if(self){
        [self getMyAppSupportedArchitectures];
    }
    return self;
}


/**
 * 根据ipa的location 解压安装组件；
 * (1) 验证安装包的有效性：主要是验证ipa的crc32值， ipa打包framework的签名
 * (2) 验证framework是否支持主app要求支持的architeture；
 * (3) 解压ipa包到指定目录
 */
-(LDFBundle *)installBundleWithPath: (NSString *)filePath{
    LDFBundle *bundle = nil;
    //验证签名
    @try {
        if(![self checkCertificate:filePath]){
            LOG(@"signatures error: %@", filePath);
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    //获取ipa中所有文件的CRC值
    //第一次解压的时候，存储ipa的CRC32值，下次运行比较CRC的值是否变化
    NSDictionary *properties = [LDFFileManager getPropertiesFromLocalBundleFile:filePath];
    long crc32OfIpa  = [LDFFileManager getCRC32:filePath];
    
    
    //解压文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *bundleCacheDir = [LDFFileManager bundleCacheDir];
    NSString *toDestInstallDir = [bundleCacheDir stringByAppendingFormat:@"/%@.%@", [properties objectForKey:BUNDLE_NAME], BUNDLE_INSTALLED_EXTENSION];
    if([fileManager fileExistsAtPath:toDestInstallDir]){
        if(![fileManager removeItemAtPath:toDestInstallDir error:&error]){
            LOG(@"delete the bundle Installed Dir: %@ failure!!!", toDestInstallDir);
        }
    }
    
    //解压成功之后，获取ipa中打包的framework支持的architeture的值
    //如果不支持，删掉刚才解压的目录
    BOOL unzipSuccess = [LDFFileManager unZipFile:filePath destPath:bundleCacheDir];
    if(unzipSuccess){
        BOOL isHasRequiredArchitetures = [self checkMatchingArchiteture:_myAppArchiteture inIpaFile:filePath];
        if(!isHasRequiredArchitetures){
            if(![fileManager removeItemAtPath:toDestInstallDir error:&error]){
                LOG(@"delete the bundle unzip Dir: %@ failure!!!", toDestInstallDir);
            }
        } else {
            bundle = [[LDFBundle alloc] initBundleWithPath:toDestInstallDir];
            if(bundle){
                bundle.crc32 = crc32OfIpa;
            }
        }
    }
    
    return bundle;
}


/**
 * 验证签名文件
 * fixme
 */
-(BOOL)checkCertificate:(NSString *)filePath{
    return YES;
}


/**
 * 判断安装组件是否支持当前host程序要求的architeture
 */
-(BOOL)checkMatchingArchiteture:(NSArray *)hostArchitetures inIpaFile:(NSString *)filePath {
    return YES;
}


-(void)getMyAppSupportedArchitectures {
    _myAppArchiteture = [NSBundle mainBundle].executableArchitectures;
}


/**
 * 根据bundleIdentifier 卸载已安装的组件
 * (1) 删除ipa文件
 * (2) 删除ipa的安装目录
 */
-(BOOL)uninstallBundle:(NSString *)bundleName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *bundleCacheDir = [LDFFileManager bundleCacheDir];
    
    //卸载安装目录
    NSString *toDestInstallDir = [bundleCacheDir stringByAppendingFormat:@"/%@.%@", bundleName, BUNDLE_INSTALLED_EXTENSION];
    if([fileManager fileExistsAtPath:toDestInstallDir]){
        if(![fileManager removeItemAtPath:toDestInstallDir error:&error]){
            LOG(@"uninstall framework %@ error: %@", toDestInstallDir, [error description]);
        }
    }
    
    //删除安装文件
    NSString *ipaFilePath = [bundleCacheDir stringByAppendingFormat:@"/%@.%@", bundleName, BUNDLE_EXTENSION];
    if([fileManager fileExistsAtPath:ipaFilePath]){
        if(![fileManager removeItemAtPath:ipaFilePath error:&error]){
            LOG(@"delete ipa file %@ error: %@", ipaFilePath, [error description]);
        }
    }
    
    return YES;
}



@end
