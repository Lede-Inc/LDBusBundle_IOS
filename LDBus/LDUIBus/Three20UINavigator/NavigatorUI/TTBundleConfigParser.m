//
//  AppDelegate.m
//  MovieStartupBundle
//
//  Created by 庞辉 on 11/21/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "TTBundleConfigParser.h"


#define IFNIL(XX) (((XX)==nil)?@"":(XX))

@implementation TTFrameworkBundleObj
@synthesize bundleName =_bundleName;
@synthesize bundleWebHost =_bundleWebHost;
@synthesize updateURL = _updateURL;
@synthesize installLevel = _installLevel;
@synthesize connectorClass = _connectorClass;
@synthesize urlCtrlArray = _urlCtrlArray;
@synthesize serviceMap = _serviceMap;
@synthesize messageMap = _messageMap;
@end

@implementation TTURLViewControlObj
@synthesize viewCtrlName = _viewCtrlName;
@synthesize viewCtrlClass = _viewCtrlClass;
@synthesize viewCtrlWebPath = _viewCtrlWebPath;
@synthesize viewCtrlDefaultType = _viewCtrlDefaultType;
@synthesize viewCtrlDefaultParent = _viewCtrlDefaultParent;
@synthesize patternArray = _patternArray;

@end


@implementation TTURLPatternObj
@synthesize patternWebPath = _patternWebPath;
@synthesize patternWebQuery = _patternWebQuery;
@synthesize patternWebFrage = _patternWebFrage;
@synthesize patternType = _patternType;
@synthesize patternParent = _patternParent;

@end


@interface TTBundleConfigParser () {
    NSString *bundleName;
    NSString *viewCtrlName; 
    NSString *urlPatternName;
}
@end


@implementation TTBundleConfigParser
@synthesize frameworkBundle = _frameworkBundle;

- (id)init
{
    self = [super init];
    if (self != nil) {
        bundleName = nil;
        viewCtrlName = nil;
        urlPatternName = nil;
    }
    return self;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    //存储webview的配置选项
    if ([elementName isEqualToString:@"bundle"]) {
        bundleName = IFNIL(attributeDict[@"name"]);
        _frameworkBundle = [[TTFrameworkBundleObj alloc] init];
        _frameworkBundle.bundleName = IFNIL(attributeDict[@"name"]);
        _frameworkBundle.bundleWebHost = IFNIL(attributeDict[@"host"]);
        _frameworkBundle.updateURL = IFNIL(attributeDict[@"update"]);
        _frameworkBundle.installLevel = IFNIL(attributeDict[@"installLevel"]);
        _frameworkBundle.connectorClass = IFNIL(attributeDict[@"connectorClass"]);
    } else if([elementName isEqualToString:@"ViewController"]) {
        if(_frameworkBundle.urlCtrlArray == nil){
            _frameworkBundle.urlCtrlArray = [[NSMutableArray alloc] initWithCapacity:2];
        }
        viewCtrlName = IFNIL(attributeDict[@"name"]);
        if(_frameworkBundle && viewCtrlName && ![viewCtrlName isEqualToString:@""]){
            TTURLViewControlObj *urlCtrl = [[TTURLViewControlObj alloc] init];
            urlCtrl.viewCtrlName = IFNIL(attributeDict[@"name"]);
            urlCtrl.viewCtrlClass = IFNIL(attributeDict[@"class"]);
            urlCtrl.viewCtrlWebPath = IFNIL(attributeDict[@"webpath"]);
            urlCtrl.viewCtrlDefaultType = [self getTypeFromString:IFNIL(attributeDict[@"type"])];
            urlCtrl.viewCtrlDefaultParent =IFNIL(attributeDict[@"parent"]);
            [_frameworkBundle.urlCtrlArray addObject:urlCtrl];
        }
    } else if([elementName isEqualToString:@"Service"]){
        if(_frameworkBundle.serviceMap == nil) {
            _frameworkBundle.serviceMap = [[NSMutableDictionary alloc] initWithCapacity:2];
        }
        NSString *serviceName = IFNIL(attributeDict[@"name"]);
        NSString *serviceClass = IFNIL(attributeDict[@"class"]);
        if(![serviceName isEqualToString:@""] && ![serviceClass isEqualToString:@""]){
            serviceName = [NSString stringWithFormat:@"%@.%@", _frameworkBundle.bundleName, serviceName];
            [_frameworkBundle.serviceMap setObject:serviceClass forKey:serviceName];
        }
        
    } else if([elementName isEqualToString:@"Message"]) {
        if(_frameworkBundle.messageMap == nil) {
            _frameworkBundle.messageMap = [[NSMutableDictionary alloc] initWithCapacity:2];
        }
        NSString *messageName = IFNIL(attributeDict[@"name"]);
        NSString *messageClass = IFNIL(attributeDict[@"class"]);
        if(![messageName isEqualToString:@""] && ![messageClass isEqualToString:@""]){
            messageName = [NSString stringWithFormat:@"%@.%@", _frameworkBundle.bundleName, messageName];
            [_frameworkBundle.messageMap setObject:messageClass forKey:messageName];
        }
    } else if([elementName isEqualToString:@"URLPattern"]) {
        urlPatternName = IFNIL(attributeDict[@"name"]);
        if(_frameworkBundle && _frameworkBundle.urlCtrlArray && urlPatternName){
            TTURLViewControlObj *last = [_frameworkBundle.urlCtrlArray lastObject];
            if(last.patternArray == nil){
                last.patternArray = [[NSMutableArray alloc] initWithCapacity:2];
            }
            TTURLPatternObj *pattern = [[TTURLPatternObj alloc] init];
            pattern.patternWebPath = IFNIL(attributeDict[@"name"]);
            // 将query中的；参数转化成&参数，因为&参数造成xml不合法
            pattern.patternWebQuery = [IFNIL(attributeDict[@"webquery"]) stringByReplacingOccurrencesOfString:@";" withString:@"&"];
            pattern.patternWebFrage = IFNIL(attributeDict[@"webfrage"]);
            pattern.patternType = [self getTypeFromString:IFNIL(attributeDict[@"type"])];
            pattern.patternParent = IFNIL(attributeDict[@"parent"]);
            [last.patternArray addObject:pattern];
        }
        
    }
}


-(PatternType)getTypeFromString:(NSString *)str {
    NSString *tmp = [str lowercaseString];
    PatternType type = PatternNone;
    if([tmp isEqualToString:@"push"]){
        type = PatternPush;
    } else if([tmp isEqualToString:@"pop"]){
        type = PatternPop;
    }else if([tmp isEqualToString:@"modal"]){
        type = PatternModal;
    }else if([tmp isEqualToString:@"share"]){
        type = PatternShare;
    } else {
        type = PatternPush;
    }
    
    return type;
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName
{
    if ([elementName isEqualToString:@"bundle"]) {
        // no longer handling a feature so release
        bundleName = nil;
    } else if ([elementName isEqualToString:@"ViewController"]){
        viewCtrlName = nil;
    } else if ([elementName isEqualToString:@"URLPattern"]) {
        urlPatternName = nil;
    }
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    NSAssert(NO, @"xml parse error line %ld col %ld", (long)[parser lineNumber], (long)[parser columnNumber]);
}

@end
