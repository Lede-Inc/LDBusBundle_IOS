//
//  LDFCommonDef.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/10/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFCommonDef.h"


int const STATUS_SCUCCESS = 1;
int const STATUS_ERR_DOWNLOAD = -1;
int const STATUS_ERR_INSTALL = -2;
int const STATUS_ERR_CANCEL = -3;


//获取bundle中的info.plist的属性
//bundle签名 @"CFBundleSignature"
//最低支持版本 @"MinimumOSVersion"
//bundle类型 @"CFBundlePackageType"
//bundle版本号 @"CFBundleShortVersionString"
//bundle build版本号 @"CFBundleVersion"
//版本名字 @"CFBundleName"

NSString * const BUNDLE_PACKAGENAME = @"CFBundleIdentifier";
NSString * const BUNDLE_NAME = @"CFBundleName";
NSString * const BUNDLE_MAIN_ACTIVITY = @"Bundle-MainActivity";
NSString * const BUNDLE_ICON_URL = @"Bundle-Icon";
NSString * const BUNDLE_UPDATE_URL = @"Bundle-UpdateUrl";
NSString * const BUNDLE_SIZE = @"Bundle-Size";

NSString * const MIN_FRAMEWORK_VERSION = @"Framework-Version";
NSString * const MIN_HOST_VERSION = @"Host-Version";
NSString * const HOST_VERSIONCODE = @"hostVersionCode";
NSString * const BUNDLE_LOCATION = @"Bundle-Location";

NSString * const EXPORT_PACKAGE = @"Export-Package";
NSString * const EXPORT_SERVICE = @"Export-Service";
NSString * const IMPORT_PACKAGE = @"Import-Package";
NSString * const IMPORT_SERVICE = @"Import-Service";
NSString * const BUNDLE_VENDOR = @"Bundle-Vendor";
NSString * const BUNDLE_VERSION = @"CFBundleShortVersionString";

NSString * const BUNDLE_VERSION_CODE = @"Bundle-VersionCode";
NSString * const BUNDLE_ACTIVATOR = @"Bundle-Activator";
NSString * const BUNDLE_AUTO_STARTUP = @"Bundle-AutoStartup";

// 0 不自动下载；1 仅WIFI下自动下载； 2 任意网络自动下载
NSString * const BUNDLE_INSTALL_LEVEL = @"Bundle-InstallLevel";

NSString * const OBJECTCLASS = @"Object-Class";

NSString * const SERVICE_ID = @"Service-ID";

NSString * const INSTALL_DIR = @"bundles";
NSString * const DEX_OUT_DIR = @"dex";
NSString * const PROPERTIES_PATH = @"assets/plugin.properties";// apk包中插件属性文件

NSString * const CLASS_NAME = @"Bundle-ClassName";

/**
 * 比较两个string版本号的大小 ver1, ver2
 * ver1 > ver2  return 1
 * ver1 = ver2  return 0
 * ver1 < ver2  return -1
 * 如果参数无效，返回－2
 */
static NSString *regex = @"^[0-9](.[0-9]){0,4}$";
int versionCompare(NSString *ver1, NSString *ver2){
    if(!ver1 || [ver1 isEqualToString:@""] ||
       !ver2 || [ver2 isEqualToString:@""]) return -2;
    NSSet *speicilSet = [NSSet setWithArray:@[@"0.0", @"0.0.0", @"0.0.0.0", @"0.0.0.0.0", @".", @".."]];
    if([speicilSet containsObject:ver1] || [speicilSet containsObject:ver2]) return -2;
    
    //验证是否包括其他字符
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger num1 = [reg numberOfMatchesInString:ver1 options:0 range:NSMakeRange(0, [ver1 length])];
    NSInteger num2 = [reg numberOfMatchesInString:ver2 options:0 range:NSMakeRange(0, [ver2 length])];
    if(num1 <= 0 || num2 <= 0){
        return -2;
    }
    
    //对版本字符串进行分割比较
    if([ver1 isEqualToString:ver2]) return 0;
    NSArray *ver1Arr = [ver1 componentsSeparatedByString:@"."];
    NSArray *ver2Arr = [ver2 componentsSeparatedByString:@"."];
    NSUInteger minLength = ver1Arr.count > ver2Arr.count ? ver2Arr.count:ver1Arr.count;
    int result = 0;
    for(int i = 0; i < minLength; i++){
        int m = [ver1Arr[i] intValue];
        int n = [ver2Arr[i] intValue];
        if(m > n){
            result = 1;
            break;
        } else if( m < n){
            result = -1;
            break;
        } else {
            continue;
        }
    }
    
    if(result != 0) return result;
    
    //处理前面都相同的情况
    if(minLength < ver1Arr.count){
        return 1;
    }
    
    if(minLength < ver2Arr.count){
        return -1;
    }
    
    return 0;
}

