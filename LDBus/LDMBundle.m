//
//  LDMBundle.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDMBundleConfigParser.h"
#import "LDMBundleConfigurationItem.h"
#import "LDMURLViewCtrlConfigurationItem.h"
#import "LDMURLViewCtrlPatternConfigurationItem.h"

#import "LDMBusContext.h"
#import "LDMBundle.h"
#import "LDMUIBusConnector.h"
#import "TTURLMap.h"
#import "TTWebController.h"

//获取系统版本
#define INTOSVERSION ([[[UIDevice currentDevice] systemVersion] intValue])

@implementation LDMBundle
@synthesize configurationItem = _configurationItem;
@synthesize uibusConnetor = _uibusConnetor;
@synthesize updateURL = _updateURL;
@synthesize InstallLevel = _installLevel;
@synthesize state = _state;
@synthesize isDynamic = _isDynamic;
@synthesize scheme = _scheme;

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
        return _configurationItem.bundleName;
    }
}

-(void)setBundleNavigator:(LDMNavigator *)navigator{
    _navigator = navigator;
}


-(void)setBundleScheme:(NSString *)scheme {
    if(scheme && ![scheme isEqualToString:@""]){
        _scheme = scheme;
    }
}


/**
 * 统一加载Bundle的Config配置到bundle中
 */
-(BOOL) loadStaticBundleConfigToMap:(NSString *)bundlePath{
    NSString  *configPath = [bundlePath stringByAppendingPathComponent:@"busconfig.xml"];
    if([[NSFileManager defaultManager] fileExistsAtPath:configPath]){
        LDMBundleConfigParser *delegate = [[LDMBundleConfigParser alloc] init];
        NSXMLParser *configParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:configPath]];
        if (configParser == nil) {
            //xml路径有效性进行验证
            NSAssert(@"Failed to initialize XML parser:>>>path=%@", configPath);
            return NO;
        }
        [configParser setDelegate:((id < NSXMLParserDelegate >)delegate)];
        [configParser parse];
        _configurationItem = delegate.configurationItem;
        
        return YES;
    }
    
    return NO;
}

/**
 * 从config中获取bundle服务配置项列表
 */
-(NSArray* ) getServiceConfigurationList{
    if(_configurationItem == nil) return nil;
    
    if(_configurationItem.serviceConfigurationList && _configurationItem.serviceConfigurationList.count>0){
        return _configurationItem.serviceConfigurationList;
    } else {
        return nil;
    }
}



/**
 * 从config中获取bundle发送消息配置项列表
 */
-(NSArray *) getPostMessageConfigurationList {
    if(_configurationItem == nil) return nil;
    if(_configurationItem.postMessageConfigurationList && _configurationItem.postMessageConfigurationList.count>0){
        return _configurationItem.postMessageConfigurationList;
    } else {
        return nil;
    }
}


/**
 * 从config中获取bundle接受消息配置项列表
 */
-(NSArray *) getReceiveMessageConfigurationList{
    if(_configurationItem == nil) return nil;
    if(_configurationItem.receiveMessageConfigurationList && _configurationItem.receiveMessageConfigurationList.count>0){
        return _configurationItem.receiveMessageConfigurationList;
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
    if(_configurationItem == nil) return NO;
    
    //bundle指定了connector
    if(![_configurationItem.connectorClass isEqualToString:@""]){
        Class connctorClass = [NSClassFromString(_configurationItem.connectorClass) class];
        if(connctorClass != nil){
            id obj = [[connctorClass alloc] init];
            if([obj isKindOfClass:[LDMUIBusConnector class]]){
                _uibusConnetor = obj;
            }
        }
    }
    
    //否则，bus总线自动为bundle初始化一个
    if(_uibusConnetor == nil) {
        _uibusConnetor = [[LDMUIBusConnector alloc] init];
    }
    
    //初始化完成之后赋值map
    if(_uibusConnetor != nil) {
        //根据bundle的navigator设置UIBusConnector
        if(_navigator){
            [_uibusConnetor setGlobalNavigator:_navigator];
        }
        [_uibusConnetor setBelongBundle:_configurationItem.bundleName];
        [_uibusConnetor setBundleURLMap:[self getURLMapFromConfigObj]];
    }
    return YES;
}


/**
 * 从解析的configObj获取供其他bundle调用的UI总线的map
 */
-(TTURLMap *)getURLMapFromConfigObj{
    if(_configurationItem == nil) return nil;
    TTURLMap *map = [[TTURLMap alloc] init];
    [map from:@"*" toViewController:[TTWebController class] withWebURL:nil];
    if(_configurationItem.urlViewCtrlConfigurationList && _configurationItem.urlViewCtrlConfigurationList.count>0){
        //设置bundle URLMap的scheme
        NSString *bundleScheme = _configurationItem.bundleName;
        if(_scheme && ![_scheme isEqualToString:@""]) {
            bundleScheme = _scheme;
        }
        
        for(int i = 0; i < _configurationItem.urlViewCtrlConfigurationList.count; i++){
            //设置每个viewctrl默认的打开方式
            LDMURLViewCtrlConfigurationItem *viewCtrl = _configurationItem.urlViewCtrlConfigurationList[i];
            NSString *baseCtrlPatternURL = [NSString stringWithFormat:@"%@://%@", bundleScheme, viewCtrl.viewCtrlName];
            NSString *baseCtrlPatternWebURL = [NSString stringWithFormat:@"%@%@",_configurationItem.bundleWebHost,viewCtrl.viewCtrlWebPath];
            
            //加query参数：
            NSString *queryItem = [viewCtrl.viewCtrlWebQuery isEqualToString:@""]?@"": [NSString stringWithFormat:@"?%@", viewCtrl.viewCtrlWebQuery];
            NSString *ctrlPatternURL = [baseCtrlPatternURL stringByAppendingString:queryItem];
            NSString *ctrlPatternWebURL = [baseCtrlPatternWebURL stringByAppendingString:queryItem];
            
            NSString *ctrlPatternParent = [viewCtrl.viewCtrlDefaultParent isEqualToString:@""]?@"": [NSString stringWithFormat:@"%@://%@", bundleScheme, viewCtrl.viewCtrlDefaultParent];
            [self setNaviagtorMap:map MapURL:ctrlPatternURL webURL:ctrlPatternWebURL ctrlClass:viewCtrl.viewCtrlClass parent:ctrlPatternParent type:viewCtrl.viewCtrlDefaultType];
            
            //设置viewctrl各个pattern的map
            if(viewCtrl.urlViewCtrlPatternConfigurationList && viewCtrl.urlViewCtrlPatternConfigurationList.count>0){
                for(int j = 0; j < viewCtrl.urlViewCtrlPatternConfigurationList.count; j++){
                    LDMURLViewCtrlPatternConfigurationItem *urlPattern = [viewCtrl.urlViewCtrlPatternConfigurationList objectAtIndex:j];
                    if(![urlPattern.patternWebPath isEqualToString:@""]
                       ||![urlPattern.patternWebQuery isEqualToString:@""]
                       || ![urlPattern.patternWebFrage isEqualToString:@""]){
                        NSString *path = [urlPattern.patternWebPath isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"/%@", urlPattern.patternWebPath];
                        NSString *query = [urlPattern.patternWebQuery isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"?%@", urlPattern.patternWebQuery];
                        NSString *fragement = [urlPattern.patternWebFrage isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"#%@", urlPattern.patternWebFrage];
                        NSString *patternURL = [baseCtrlPatternURL stringByAppendingFormat:@"%@%@%@",path,query, fragement];
                        NSString *patternWebURL = [baseCtrlPatternWebURL stringByAppendingFormat:@"%@%@", query, fragement];
                        NSString *patternParent = [urlPattern.patternParent isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"%@://%@", bundleScheme, urlPattern.patternParent];
                        [self setNaviagtorMap:map MapURL:patternURL webURL:patternWebURL ctrlClass:viewCtrl.viewCtrlClass parent:patternParent type:urlPattern.patternType];
                    }
                }
            }
        }
    }
    
    return map;
}


-(void) setNaviagtorMap:(TTURLMap *)map MapURL:(NSString *)URL webURL:(NSString *)webURL ctrlClass:(NSString *)ctrlClass parent:(NSString *) parent type:(PatternType) type {
#ifdef DEBUG
    //bundle内部：首先对weburl为空时，ctrlClass必须存在
    if(webURL == nil || [webURL isEqualToString:@""]){
        if([NSClassFromString(ctrlClass) class] == nil){
            NSAssert(NO, @"bundle %@ parse url: %@ error for ctrlClass(%@) is nil and webURL is empty",_configurationItem.bundleName, URL, ctrlClass);
        }
    }
    
    //检查bundle内部URL是否重复
    if( [map matchObjectPattern:[NSURL URLWithString:URL]] != [map defaultObjectPattern]){
        NSAssert(NO, @"bundle %@ parse url: %@ of viewCtrl(%@) is duplicate in bundle",_configurationItem.bundleName, URL, ctrlClass);
    }
#endif
    
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

/**
 * 和容器内的其他bundle进行比较，是否有重复的URLPattern
 * 引入匹配url pattern的时候不匹配scheme，所以重复性不检查scheme
 */
-(void) checkDuplicateURLPattern:(LDMBundle *)aBundle{
    if(_configurationItem && aBundle.configurationItem){
        //获得当前bundle的scheme
        /*
        NSString *bundleScheme = _configurationItem.bundleName;
        if(_scheme && ![_scheme isEqualToString:@""]) {
            bundleScheme = _scheme;
        }
         */
        
        NSLog(@">>>>>>>>>>>>>check Bunde: %@>>>>>>>>>>>>>>>>", _configurationItem.bundleName);
        for(int i = 0; i < _configurationItem.urlViewCtrlConfigurationList.count; i++){
            //检查viewctrl默认的打开方式在abundle是否存在，只要viewctrl不重复，pattern选项自然不重复
            LDMURLViewCtrlConfigurationItem *viewCtrl = _configurationItem.urlViewCtrlConfigurationList[i];
            NSString *ctrlPatternURL = [NSString stringWithFormat:@"%@", viewCtrl.viewCtrlName];
            
            //获得aBundle的scheme
            /*
            NSString *aBundleScheme = aBundle.configurationItem.bundleName;
            if(aBundle.scheme && ![aBundle.scheme isEqualToString:@""]) {
                aBundleScheme = aBundle.scheme;
            }
             */
            
            for(int j= 0; j < aBundle.configurationItem.urlViewCtrlConfigurationList.count; j++){
                LDMURLViewCtrlConfigurationItem *aBundleViewCtrl = aBundle.configurationItem.urlViewCtrlConfigurationList[j];
                NSString *aBundleCtrlPatternURL = [NSString stringWithFormat:@"%@", aBundleViewCtrl.viewCtrlName];
                if([ctrlPatternURL isEqualToString:aBundleCtrlPatternURL]){
                    NSAssert(NO, @">>>>ViewCtrl(%@) exist duplicate url pattern in bundle(%@)>>>>>", viewCtrl.viewCtrlName, aBundle.configurationItem.bundleName);
                }
            }
            
        }
        NSLog(@">>>>>>>>>>>>>check end>>>>>>>>>>>>>>>>>>>>>>");
    }
}

@end
