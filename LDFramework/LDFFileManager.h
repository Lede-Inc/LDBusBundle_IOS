//
//  LDFFileManager.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOCAL_BUNDLES_DIR @"bundles"
#define BUNDLE_EXTENSION @"ipa"
#define BUNDLE_INSTALLED_EXTENSION @"framework"
#define INFO_PLIST @"Info.plist"

/**
 * @class LDFFileManager 对框架涉及到的所有文件进行管理
 *
 */
@interface LDFFileManager : NSObject {
    
}

/**
 * 获取Bundle存储的目录
 * @return bundle存储目录
 */
+(NSString *) bundleCacheDir;


/**
 * 从给定file路径读取bundle的配置信息
 */
+(NSDictionary *)getPropertiesFromLocalBundleFile:(NSString *)bundleFilePath;


/**
 * 从zip文件解压到指定位置
 */
+(BOOL)unZipFile:(NSString *)filePath destPath:(NSString *)destPath;


/**
 * 获取ipa文件的CRC值
 */
+(long)getCRC32:(NSString *)filePath;

/**
 * 将下载的zip文件重命名
 */
+(BOOL)renameNewDownloadFileWithName: (NSString *)bundleName;

@end
