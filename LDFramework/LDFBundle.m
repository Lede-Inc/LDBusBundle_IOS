//
//  LDFBundle.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDFBundle.h"
#import "LDFCommonDef.h"
#import "LDFFileManager.h"

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
    NSBundle *_bundle;
}

@property (nonatomic, readwrite) NSMutableDictionary *infoDictionary;
@end


@implementation LDFBundle
@synthesize state = _state;
@synthesize crc32 = _crc32;
@synthesize update = _update;
@synthesize infoDictionary = _infoDictionary;
@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize version = _version;
@synthesize versionCode = _versionCode;
@synthesize updateURL = _updateURL;
@synthesize autoStartup = _autoStartup;
@synthesize size = _size;
@synthesize installLocation = _installLocation;
@synthesize principalClass = _principalClass;
@synthesize exportServices = _exportServices;
@synthesize importServices = _importServices;
@synthesize autoInstallLevel = _autoInstallLevel;
@synthesize minFrameworkVersion = _minFrameworkVersion;
@synthesize minHostAppVersion = _minHostAppVersion;


#pragma mark bundle selector
-(id) initBundleWithInfoDictionary:(NSDictionary *)theInfoDictionary{
    self = [super init];
    if(self){
        _bundle = nil;
        _state = UNINSTALLED;
        _infoDictionary = [NSMutableDictionary dictionaryWithDictionary:theInfoDictionary];
    }
    
    return self;
}

-(id) initBundleWithPath:(NSString *)path {
    self = [super init];
    if(self){
        if([path.lastPathComponent hasSuffix:BUNDLE_INSTALLED_EXTENSION] && IOSVERSION >= 7){
            _bundle = [NSBundle bundleWithPath:path];
            if(_bundle){
                [self.infoDictionary setObject:path forKey:BUNDLE_LOCATION];
            }
            _state = INSTALLED;
        }
    }
    
    return self;
}


-(BOOL)instanceDynamicBundle:(NSString *)path {
    if([path.lastPathComponent hasSuffix:BUNDLE_INSTALLED_EXTENSION] && IOSVERSION >= 7){
        if(_bundle && [_bundle isLoaded]){
            [_bundle unload];
            _bundle = nil;
        }
        
        _bundle = [NSBundle bundleWithPath:path];
        if(_bundle){
            [self.infoDictionary setObject:path forKey:BUNDLE_LOCATION];
        }
        _state = INSTALLED;
        return YES;
    } else {
        return NO;
    }
}



-(BOOL)start {
    if(_bundle && ![_bundle isLoaded]){
        return [_bundle load];
    } else {
        return YES;
    }
}


-(BOOL)stop {
    if(_bundle && [_bundle isLoaded]){
        return [_bundle unload];
    } else {
        return YES;
    }
}


-(BOOL)isLoaded {
    if(_bundle){
        return [_bundle isLoaded];
    } else{
        return NO;
    }
}


-(int)state {
    return _state;
}


-(BOOL)isEqual:(id)obj{
    if([obj isKindOfClass:[LDFBundle class]]){
        return [[(LDFBundle *)obj identifier] isEqualToString:self.identifier];
    }
    
    return NO;
}



#pragma mark - bundle infodictionary
-(NSDictionary *) infoDictionary {
    if(_bundle){
        _infoDictionary = nil;
        return _bundle.infoDictionary;
    } else {
        if(_infoDictionary == nil){
            _infoDictionary = [[NSMutableDictionary alloc] initWithCapacity:2];
        }
        return _infoDictionary;
    }
}


-(NSString *)name {
    return [self.infoDictionary objectForKey:BUNDLE_NAME];
}


-(NSString *)identifier {
    return [self.infoDictionary objectForKey:BUNDLE_PACKAGENAME];
}


-(NSString *)updateURL {
    return [self.infoDictionary objectForKey:BUNDLE_UPDATE_URL];
}


-(NSString *)version {
    return [self.infoDictionary objectForKey:BUNDLE_VERSION];
}


-(NSString *)versionCode{
    return [self.infoDictionary objectForKey:BUNDLE_VERSION_CODE];
}


-(BOOL) autoStartup {
    return [[self.infoDictionary objectForKey:BUNDLE_AUTO_STARTUP] boolValue];
}


-(NSString *) exportServices {
    return [self.infoDictionary objectForKey:EXPORT_SERVICE];
}


-(NSString *) importServices{
    return [self.infoDictionary objectForKey:IMPORT_SERVICE];
}


-(int)autoInstallLevel{
    id level = [self.infoDictionary objectForKey:BUNDLE_INSTALL_LEVEL];
    if(level && [level isKindOfClass:[NSString class]]){
        return [level intValue];
    }
    return INSTALL_LEVEL_NONE;
}


-(Class)principalClass{
    if(_bundle){
        return _bundle.principalClass;
    } else {
        return nil;
    }
}


-(NSString *)installLocation{
    return [self.infoDictionary objectForKey:BUNDLE_LOCATION];
}


-(long)size{
    return [[self.infoDictionary objectForKey:BUNDLE_SIZE] longValue];
}


-(NSString *)minFrameworkVersion{
    return [self.infoDictionary objectForKey:MIN_FRAMEWORK_VERSION];
}


-(NSString *)minHostAppVersion{
    return [self.infoDictionary objectForKey:MIN_HOST_VERSION];
}




@end
