//
//  LDFBundleInstaller.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFBundleInstaller.h"



@interface LDFBundleInstaller () {
    NSArray *_myAppArchiteture;
}

@end



@implementation LDFBundleInstaller
@synthesize signature;

/**
 * 根据ipa的location 解压安装组件；
 * (1) 验证安装包的有效性：主要是验证ipa的crc32值， ipa打包framework的签名
 * (2) 验证framework是否支持主app要求支持的architeture；
 * (3) 解压ipa包到指定目录
 */
-(LDFBundle *)installBundleWithPath: (NSString *)filePath{
    
    
}


-(BOOL)uninstallBundleWithName:(NSString *)bundleIdentifier{
    return YES;
}


-(void)getMyAppSupportedArchitectures {
    _myAppArchiteture = [NSBundle mainBundle].executableArchitectures;
}



@end
