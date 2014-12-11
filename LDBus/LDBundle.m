//
//  LDBundleImpl.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDBundle.h"
#import "LDUIBusConnector.h"
#import "TTURLMap.h"
#import "LDBundleConfigParser.h"
#import "TTWebController.h"

//获取系统版本
#define INTOSVERSION ([[[UIDevice currentDevice] systemVersion] intValue])

@implementation LDBundle
@synthesize uibusConnetor = _uibusConnetor;
@synthesize updateURL = _updateURL;
@synthesize InstallLevel = _installLevel;
@synthesize state = _state;
@synthesize isDynamic = _isDynamic;

-(id) initBundleWithPath:(NSString *)path {
    //处理static framework
    if([path.lastPathComponent hasSuffix:@".bundle"]){
        self = [super init];
        if(self){
            _isDynamic = NO;
            [self loadStaticBundleConfigToMap:path];
        }
        return self;
    }
    
    //处理dynamic framework, 只有ios8以上的系统才动态加载
    else if([path.lastPathComponent hasSuffix:@".framework"]){
        if(INTOSVERSION >= 7){
            self = [super initWithPath:path];
            if(self){
                _isDynamic = YES;
            }
            return self;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

//加载bundle到内存, 暂不提供，需要探索
-(BOOL)load {
    if(_isDynamic){
        return [super load];
    } else {
        return YES;
    }
}

//把bundle从内存中卸载，暂不提供，需要探索
-(BOOL)unload {
    if(_isDynamic){
        return [super unload];
    } else {
        return YES;
    }
}

//获取bundle的唯一标识
-(NSString *)bundleIdentifier {
    if(_isDynamic){
        return self.bundleIdentifier;
    } else {
        return _configObj.bundleName;
    }
}

-(void)setNavigator:(TTNavigator *)navigator{
    _navigator = navigator;
    if(_uibusConnetor){
        [_uibusConnetor setGlobalNavigator:_navigator];
    }
}


/**
 * 统一加载Bundle的Config配置到bundle中
 */
-(BOOL) loadStaticBundleConfigToMap:(NSString *)bundlePath{
    NSString  *configPath = [bundlePath stringByAppendingPathComponent:@"busconfig.xml"];
    if([[NSFileManager defaultManager] fileExistsAtPath:configPath]){
        LDBundleConfigParser *delegate = [[LDBundleConfigParser alloc] init];
        NSXMLParser *configParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:configPath]];
        if (configParser == nil) {
            NSLog(@"Failed to initialize XML parser:>>>path=%@", configPath);
            return NO;
        }
        [configParser setDelegate:((id < NSXMLParserDelegate >)delegate)];
        [configParser parse];
        _configObj = delegate.frameworkBundle;
        
        //初始化每个bundle对应的UIBusConnector
        [self setUIBusConnectorToBundle];
        return YES;
    }
    
    return NO;
}

/**
 * 从config中获取服务总线配置
 */
-(NSMutableDictionary* ) getServiceMapFromConfigObj {
    if(_configObj == nil) return nil;
    
    if(_configObj.serviceMap != nil && _configObj.serviceMap.allKeys.count>0){
        return _configObj.serviceMap;
    } else {
        return nil;
    }
}



/**
 * 从config中获取消息总线配置
 */
-(NSMutableDictionary *) getMessageMapFromConfigObj {
    if(_configObj == nil) return nil;
    
    if(_configObj.messageMap != nil && _configObj.messageMap.allKeys.count>0){
        return _configObj.messageMap;
    } else {
        return nil;
    }
}


/**
 * 给当前bundle初始化一个connector
 * 如果bundle配置文件指定connetorClass，则初始化一个指定的connetor给
 * 否则初始化一个默认的connetor给bundle
 */
-(BOOL) setUIBusConnectorToBundle {
    if(_configObj == nil) return NO;
    
    //bundle指定了connector
    if(![_configObj.connectorClass isEqualToString:@""]){
        Class connctorClass = [NSClassFromString(_configObj.connectorClass) class];
        if(connctorClass != nil){
            id obj = [[connctorClass alloc] init];
            if([obj isKindOfClass:[LDUIBusConnector class]]){
                _uibusConnetor = obj;
            }
        }
    }
    
    //否则，bus总线自动为bundle初始化一个
    if(_uibusConnetor == nil) {
        _uibusConnetor = [[LDUIBusConnector alloc] init];
    }
    
    //初始化完成之后赋值map
    if(_uibusConnetor != nil) {
        [_uibusConnetor setBundleURLMap:[self getURLMapFromConfigObj]];
    }
    return YES;
}


/**
 * 从解析的configObj获取供其他bundle调用的UI总线的map
 */
-(TTURLMap *)getURLMapFromConfigObj{
    if(_configObj == nil) return nil;
    TTFrameworkBundleObj *bundle = _configObj;
    TTURLMap *map = [[TTURLMap alloc] init];
    [map from:@"*" toViewController:[TTWebController class] withWebURL:nil];
    if(bundle.bundleName && bundle.urlCtrlArray && bundle.urlCtrlArray.count>0){
        for(int i = 0; i < bundle.urlCtrlArray.count; i++){
            //设置每个viewctrl默认的打开方式
            TTURLViewControlObj *viewCtrl = bundle.urlCtrlArray[i];
            NSString *ctrlPatternURL = [NSString stringWithFormat:@"%@://%@", bundle.bundleName, viewCtrl.viewCtrlName];
            NSString *ctrlPatternWebURL = [NSString stringWithFormat:@"%@%@",bundle.bundleWebHost,viewCtrl.viewCtrlWebPath];
            [self setNaviagtorMap:map MapURL:ctrlPatternURL webURL:ctrlPatternWebURL ctrlClass:viewCtrl.viewCtrlClass parent:viewCtrl.viewCtrlDefaultParent type:viewCtrl.viewCtrlDefaultType];
            
            //设置viewctrl各个pattern的map
            if(viewCtrl.patternArray && viewCtrl.patternArray.count>0){
                for(int j = 0; j < viewCtrl.patternArray.count; j++){
                    TTURLPatternObj *urlPattern = [viewCtrl.patternArray objectAtIndex:j];
                    if(![urlPattern.patternWebPath isEqualToString:@""]
                       ||![urlPattern.patternWebQuery isEqualToString:@""]
                       || ![urlPattern.patternWebFrage isEqualToString:@""]){
                        NSString *path = [urlPattern.patternWebPath isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"/%@", urlPattern.patternWebPath];
                        NSString *query = [urlPattern.patternWebQuery isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"?%@", urlPattern.patternWebQuery];
                        NSString *fragement = [urlPattern.patternWebFrage isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@", urlPattern.patternWebFrage];
                        NSString *patternURL = [ctrlPatternURL stringByAppendingFormat:@"%@%@%@",path,query, fragement];
                        NSString *patternWebURL = [ctrlPatternWebURL stringByAppendingFormat:@"%@%@", query, fragement];
                        [self setNaviagtorMap:map MapURL:patternURL webURL:patternWebURL ctrlClass:viewCtrl.viewCtrlClass parent:urlPattern.patternParent type:urlPattern.patternType];
                    }
                }
            }
        }
    }
    
    return map;
}


-(void) setNaviagtorMap:(TTURLMap *)map MapURL:(NSString *)URL webURL:(NSString *)webURL ctrlClass:(NSString *)ctrlClass parent:(NSString *) parent type:(PatternType) type {
    switch (type) {
        case PatternShare:
            if([parent isEqualToString:@""]){
                [map from:URL toSharedViewController:[NSClassFromString(ctrlClass) class] withWebURL:webURL];
            } else {
                [map from:URL parent:parent toSharedViewController:[NSClassFromString(ctrlClass) class] withWebURL:webURL];
            }
            break;
            
        case PatternPush:
            if([parent isEqualToString:@""]){
                [map from:URL toViewController:[NSClassFromString(ctrlClass) class] withWebURL:webURL];
            } else {
                [map from:URL parent:parent toViewController:[NSClassFromString(ctrlClass) class] selector:nil transition:0 withWebURL:webURL];
            }
            break;
            
        case PatternModal:
            if([parent isEqualToString:@""]){
                [map from:URL toModalViewController:[NSClassFromString(ctrlClass) class] withWebURL:webURL];
            } else {
                [map from:URL parent:parent toModalViewController:[NSClassFromString(ctrlClass) class] selector:nil transition:0 withWebURL:webURL];
            }
            break;
        case PatternPop:
            [map from:URL toPopoverViewController:[NSClassFromString(ctrlClass) class] withWebURL:webURL];
            break;
        default:
            break;
    }
}



@end
