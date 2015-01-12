//
//  LDFBundle.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDFBundle.h"

#define IOSVERSION ([[[UIDevice currentDevice] systemVersion] intValue])

int const UNINSTALLED = 1;
int const INSTALLED = 2;
int const INSTALLING = 4;// 正在下载安装
int const HAS_NEWVERSION = 8;
int const STARTED = 16;// 已启动
int const STOPPED = 32;// 未启动

int const INSTALL_LEVEL_NONE = 0;// 不自动安装
int const INSTALL_LEVEL_WIFI = 1;// 仅WIFI下自动安装
int const INSTALL_LEVEL_ALL = 2;// 任意网络下均自动安装


@interface LDFBundle () {
    //是否动态加载
    BOOL _isDynamic;
}

@end


@implementation LDFBundle
@synthesize state = _state;

-(id) initBundleWithPath:(NSString *)path {
    id obj = nil;
    //处理static framework
    if([path.lastPathComponent hasSuffix:@".bundle"]){
        self = [super init];
        if(self){
            _isDynamic = NO;
            obj = self;
        }
    }
    
    //处理dynamic framework, 只有ios7以上的系统才动态加载
    else if([path.lastPathComponent hasSuffix:@".framework"]){
        if(IOSVERSION >= 7){
            self = [super initWithPath:path];
            if(self){
                _isDynamic = YES;
                obj = self;
            }
        } else {
            obj =  nil;
        }
    } else {
        obj = nil;
    }
    
    if(obj){
        _state = UNINSTALLED;
        //读取.bundle或者.framework中info.plist信息
    }
    
    return obj;
}

-(BOOL)start {
    if(_isDynamic && ![self isLoaded]){
        return [self load];
    } else {
        return YES;
    }
}


-(BOOL)stop {
    if(_isDynamic && [self isLoaded]){
        return [self unload];
    } else {
        return YES;
    }
}

-(int)state {
    return _state;
}


-(NSString *)name {
    if(_isDynamic){
        return [self.infoDictionary  objectForKey:@""];
    } else {
        //返回总线配置的bundle名字
        return @"";
    }
}


-(NSString *)bundleIdentifier {
    if(_isDynamic){
        return self.bundleIdentifier;
    } else {
        //
        return @"";
    }
}



@end
