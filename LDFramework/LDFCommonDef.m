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


/*
 {
 BuildMachineOSBuild = 14B25;
 CFBundleDevelopmentRegion = English;
 CFBundleExecutable = Framework;
 CFBundleIdentifier = "com.lede.library.Framework";
 CFBundleInfoDictionaryVersion = "6.0";
 CFBundleName = Framework;
 CFBundlePackageType = FMWK;
 CFBundleShortVersionString = "1.0";
 CFBundleSignature = "????";
 CFBundleSupportedPlatforms =     (
 iPhoneOS
 );
 CFBundleVersion = 1;
 DTCompiler = "com.apple.compilers.llvm.clang.1_0";
 DTPlatformBuild = 12B411;
 DTPlatformName = iphoneos;
 DTPlatformVersion = "8.1";
 DTSDKBuild = 12B411;
 DTSDKName = "iphoneos8.1";
 DTXcode = 0611;
 DTXcodeBuild = 6A2008a;
 MinimumOSVersion = "7.0";
 NSHumanReadableCopyright = "Copyright \U00a9 2014 Damien DeVille. All rights reserved.";
 UIDeviceFamily =     (
 1
 );
 }

 */

NSString * const BUNDLE_PACKAGENAME = @"CFBundleIdentifier";
NSString * const BUNDLE_NAME = @"CFBundleName";
NSString * const BUNDLE_PRINCIPAL_CLASS = @"CFBundlePrincipalClass";
NSString * const BUNDLE_ICON_URL = @"CFBundleIcon";
NSString * const BUNDLE_UPDATE_URL = @"CFBundleUpdateUrl";
NSString * const BUNDLE_SIZE = @"CFBundleSize";

NSString * const MIN_FRAMEWORK_VERSION = @"MinFrameworkVersion";
NSString * const MIN_HOST_VERSION = @"MinHostVersion";
NSString * const HOST_VERSIONCODE = @"HostVersionCode";
NSString * const BUNDLE_LOCATION = @"CFBundleLocation";

NSString * const EXPORT_SERVICE = @"CFBundleExportService";
NSString * const IMPORT_SERVICE = @"CFBundleImportService";
NSString * const BUNDLE_VENDOR = @"NSHumanReadableCopyright";
NSString * const BUNDLE_VERSION = @"CFBundleShortVersionString";

NSString * const BUNDLE_VERSION_CODE = @"CFBundleVersion";
NSString * const BUNDLE_AUTO_STARTUP = @"CFBundleAutoStartup";

// 0 不自动下载；1 仅WIFI下自动下载； 2 任意网络自动下载
NSString * const BUNDLE_INSTALL_LEVEL = @"CFBundleInstallLevel";
NSString * const INSTALL_DIR = @"bundles";

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

