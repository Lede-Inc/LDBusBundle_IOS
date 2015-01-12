//
//  LDFBundleInstaller.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class ipa安装器
 * 负责将ipa包中的dynamic framework解压到指定位置，检查framework的签名是否跟主程序一致
 * 检查framework中是否包含主程序支持的architeture
 */
@class LDFBundle;
@interface LDFBundleInstaller : NSObject {

}
//初始化之后，设置Installer的sigNature
@property (nonatomic, assign) NSString *signature;


/**
 * 根据ipa的location 解压安装组件；
 * (1) 验证安装包的有效性：主要是验证ipa的crc32值， ipa打包framework的签名
 * (2) 验证framework是否支持主app要求支持的architeture；
 * (3) 解压ipa包到指定目录
 */
-(LDFBundle *)installBundleWithPath: (NSString *)filePath;



/**
 * 根据bundleIdentifier 卸载已安装的组件
 * (1) 删除ipa文件
 * (2) 删除ipa的安装目录
 */
-(BOOL)uninstallBundleWithName:(NSString *)bundleIdentifier;

@end
