//
//  LDFCommonDef.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/10/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CUR_FRAMEWORK_VERSION @"1.0.0"
#define CUR_HOST_VERSION ([[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"])


extern int const STATUS_SCUCCESS;
extern int const STATUS_ERR_DOWNLOAD;
extern int const STATUS_ERR_INSTALL;
extern int const STATUS_ERR_CANCEL;


extern NSString * const BUNDLE_PACKAGENAME;
extern NSString * const BUNDLE_NAME;
extern NSString * const BUNDLE_MAIN_ACTIVITY;
extern NSString * const BUNDLE_ICON_URL;
extern NSString * const BUNDLE_UPDATE_URL;
extern NSString * const BUNDLE_SIZE;

extern NSString * const MIN_FRAMEWORK_VERSION;
extern NSString * const MIN_HOST_VERSION;
extern NSString * const HOST_VERSIONCODE;
extern NSString * const BUNDLE_LOCATION;

extern NSString * const EXPORT_PACKAGE;
extern NSString * const EXPORT_SERVICE;
extern NSString * const IMPORT_PACKAGE;
extern NSString * const IMPORT_SERVICE;
extern NSString * const BUNDLE_VENDOR;
extern NSString * const BUNDLE_VERSION;

extern NSString * const BUNDLE_VERSION_CODE;
extern NSString * const BUNDLE_ACTIVATOR;
extern NSString * const BUNDLE_AUTO_STARTUP;

// 0 不自动下载；1 仅WIFI下自动下载； 2 任意网络自动下载
extern NSString * const BUNDLE_INSTALL_LEVEL;

extern NSString * const OBJECTCLASS;

extern NSString * const SERVICE_ID;

extern NSString * const INSTALL_DIR;
extern NSString * const DEX_OUT_DIR;
extern NSString * const PROPERTIES_PATH;

extern NSString * const CLASS_NAME;


/**
 * 比较两个string版本号的大小 ver1, ver2
 * ver1 > ver2  return 1
 * ver1 = ver2  return 0
 * ver1 < ver2  return -1
 */
int versionCompare(NSString *ver1, NSString *ver2);

