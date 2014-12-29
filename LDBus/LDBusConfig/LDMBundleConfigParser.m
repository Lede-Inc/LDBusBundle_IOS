//
//
//  Created by 庞辉 on 11/21/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMBundleConfigParser.h"
#import "LDMBundleConfigurationItem.h"
#import "LDMURLViewCtrlConfigurationItem.h"
#import "LDMURLViewCtrlPatternConfigurationItem.h"
#import "LDMServiceConfigurationItem.h"
#import "LDMPostMessageConfigurationItem.h"
#import "LDMReceiveMessageConfigurationItem.h"

#define IFNIL(XX) (((XX)==nil)?@"":(XX))

@interface LDMBundleConfigParser () {
    //mark
    NSString *mark_url_handler_list;
    NSString *mark_url_handler_viewcontroller;
    NSString *mark_service_list;
    NSString *mark_post_message_list;
    NSString *mark_receive_message_list;
}
@end


@implementation LDMBundleConfigParser
@synthesize configurationItem = _configurationItem;

- (id)init
{
    self = [super init];
    if (self != nil) {
        //mark
        mark_url_handler_list = nil;
        mark_url_handler_viewcontroller = nil;
        mark_service_list = nil;
        mark_post_message_list = nil;
        mark_receive_message_list = nil;
    }
    return self;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    elementName = [elementName lowercaseString];
    //存储webview的配置选项
    if ([elementName isEqualToString:@"bundle"]) {
        [self parser:parser attributes:attributeDict parseEmptyKeyParams:@[@"name"] nameSpace:elementName];
        _configurationItem = [[LDMBundleConfigurationItem alloc]
                              initWithBundleConfigurationItem:IFNIL(attributeDict[@"name"])
                              isMain:[IFNIL(attributeDict[@"is_main_bundle"]) boolValue]
                              hasFirstEnterVC:[IFNIL(attributeDict[@"hasFirstEnterVC"]) boolValue]
                              hasBundleImage:[IFNIL(attributeDict[@"hasBundleImage"]) boolValue]
                              bundleHost:IFNIL(attributeDict[@"host"])
                              updateURL:IFNIL(attributeDict[@"update"])
                              installLevel:IFNIL(attributeDict[@"installLevel"])
                              connectorClass:IFNIL(attributeDict[@"connectorClass"])];
    }
    
    //标记是否有url_handler_list,如果存在，才开始解析ViewController
    else if([elementName isEqualToString:@"url_handler_list"]){
        mark_url_handler_list = @"url_handler_list";
    }
    else if([elementName isEqualToString:@"viewcontroller"]) {
        if(mark_url_handler_list != nil) {
            mark_url_handler_viewcontroller = @"viewcontroller";
            if(_configurationItem.urlViewCtrlConfigurationList == nil){
                _configurationItem.urlViewCtrlConfigurationList = [[NSMutableArray alloc] initWithCapacity:2];
            }
            //check
            [self parser:parser attributes:attributeDict parseEmptyKeyParams:@[@"name", @"class"] nameSpace:elementName];
            NSString *viewCtrlName = IFNIL(attributeDict[@"name"]);
            if(_configurationItem && viewCtrlName && ![viewCtrlName isEqualToString:@""]){
                LDMURLViewCtrlConfigurationItem *urlViewCtrlConfigurationItem = [[LDMURLViewCtrlConfigurationItem alloc] initWithURLViewCtrlConfigurationItem:viewCtrlName class:IFNIL(attributeDict[@"class"]) webPath:IFNIL(attributeDict[@"webpath"]) webQuery: [IFNIL(attributeDict[@"webquery"]) stringByReplacingOccurrencesOfString:@";" withString:@"&"] parent:IFNIL(attributeDict[@"parent"]) type:[self getTypeFromString:IFNIL(attributeDict[@"type"])]];
                [_configurationItem.urlViewCtrlConfigurationList addObject:urlViewCtrlConfigurationItem];
            }
        }
    }
    
    else if([elementName isEqualToString:@"urlpattern"]) {
        //只有解析了url_handler_list 和 handler_viewcontroller，才开始解析pattern
        if(mark_url_handler_list && mark_url_handler_viewcontroller){
            //check
            [self parser:parser attributes:attributeDict parseEmptyKeyParams:@[@"name"] nameSpace:elementName];
            NSString *urlPatternName = IFNIL(attributeDict[@"name"]);
            if(_configurationItem && _configurationItem.urlViewCtrlConfigurationList && urlPatternName){
                LDMURLViewCtrlConfigurationItem *last = [_configurationItem.urlViewCtrlConfigurationList lastObject];
                if(last.urlViewCtrlPatternConfigurationList == nil){
                    last.urlViewCtrlPatternConfigurationList = [[NSMutableArray alloc] initWithCapacity:2];
                }
                LDMURLViewCtrlPatternConfigurationItem *urlViewCtrlPatternConfigurationItem = [[LDMURLViewCtrlPatternConfigurationItem alloc] initWithURLViewCtrlPatternConfigurationItem:IFNIL(attributeDict[@"name"]) query:[IFNIL(attributeDict[@"webquery"]) stringByReplacingOccurrencesOfString:@";" withString:@"&"] fragement:IFNIL(attributeDict[@"webfrage"]) type:[self getTypeFromString:IFNIL(attributeDict[@"type"])] parent:IFNIL(attributeDict[@"parent"])];
                [last.urlViewCtrlPatternConfigurationList addObject:urlViewCtrlPatternConfigurationItem];
            }
        }
    }
    
    //标记是否有service_list, 如果存在，才开始解析service列表
    else if([elementName isEqualToString:@"service_list"]){
        mark_service_list = @"service_list";
    }
    else if([elementName isEqualToString:@"service"]){
        if(mark_service_list != nil){
            //check
            [self parser:parser attributes:attributeDict parseEmptyKeyParams:@[@"name", @"class", @"protocol"] nameSpace:elementName];
            if(_configurationItem.serviceConfigurationList == nil) {
                _configurationItem.serviceConfigurationList = [[NSMutableArray alloc] initWithCapacity:2];
            }
            LDMServiceConfigurationItem *serviceConfigurationItem = [[LDMServiceConfigurationItem alloc] initWithServiceConfigurationItem:IFNIL(attributeDict[@"name"]) protocol:IFNIL(attributeDict[@"protocol"]) class:IFNIL(attributeDict[@"class"])];
            [_configurationItem.serviceConfigurationList addObject:serviceConfigurationItem];
        }
        
    }
    
    
    //标记是否有post, 如果存在，才开始解析service列表
    else if([elementName isEqualToString:@"post_message_list"]){
        mark_post_message_list = @"post_message_list";
    }
    
    else if([elementName isEqualToString:@"postmessage"]) {
        if(mark_post_message_list != nil){
            //check
            [self parser:parser attributes:attributeDict parseEmptyKeyParams:@[@"name", @"code"] nameSpace:elementName];
            if(_configurationItem.postMessageConfigurationList == nil) {
                _configurationItem.postMessageConfigurationList = [[NSMutableArray alloc] initWithCapacity:2];
            }
        
            LDMPostMessageConfigurationItem *postMessageConfigurationItem = [[LDMPostMessageConfigurationItem alloc] initWithPostMessageConfigurationItem:IFNIL(attributeDict[@"name"]) code:IFNIL(attributeDict[@"code"])];
            [_configurationItem.postMessageConfigurationList addObject:postMessageConfigurationItem];
        }
    }
    
    //标记是否有receive_message_list, 如果存在，才开始解析service列表
    else if([elementName isEqualToString:@"receive_message_list"]){
        mark_receive_message_list = @"receive_message_list";
    }
    
    else if([elementName isEqualToString:@"recvmessage"]) {
        if( mark_receive_message_list != nil){
            //check
            [self parser:parser attributes:attributeDict parseEmptyKeyParams:@[@"code", @"class"] nameSpace:elementName];
            if(_configurationItem.receiveMessageConfigurationList == nil) {
                _configurationItem.receiveMessageConfigurationList = [[NSMutableArray alloc] initWithCapacity:2];
            }
        
            LDMReceiveMessageConfigurationItem *receiveMessageConfigurationItem = [[LDMReceiveMessageConfigurationItem alloc] initWithReceiveMessageConfigurationItem:IFNIL(attributeDict[@"name"]) code:IFNIL(attributeDict[@"code"]) receiveObject: IFNIL(attributeDict[@"class"])];
            [_configurationItem.receiveMessageConfigurationList addObject:receiveMessageConfigurationItem];
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
    elementName = [elementName lowercaseString];
    //mark url_handler_list 解析完毕
    if([elementName isEqualToString:@"url_handler_list"]){
        mark_url_handler_list = nil;
    }
    
    else if([elementName isEqualToString:@"viewcontroller"]){
        mark_url_handler_viewcontroller = nil;
    }
    
    else if([elementName isEqualToString:@"service_list"]){
        mark_service_list = nil;
    }
    
    else if([elementName isEqualToString:@"post_message_list"]){
        mark_post_message_list = nil;
    }
    
    else if([elementName isEqualToString:@"receive_message_list"]){
        mark_receive_message_list = nil;
    }
}


/**
 * 在debug状态下，对关键参数为空进行检查
 */
-(void) parser:(NSXMLParser *)parser attributes:(NSDictionary*)attributeDict parseEmptyKeyParams:(NSArray *)keyParams nameSpace:(NSString *)nameSpace {
#ifdef DEBUG
    if(keyParams && keyParams.count > 0){
        for(int i=0; i<keyParams.count; i++){
            NSString *keyParam = [keyParams objectAtIndex:i];
            NSString *keyParamValue = attributeDict[keyParam];
            //关键参数不允许为空
            if(keyParamValue == nil || [keyParamValue isEqualToString:@""]){
                NSAssert(NO, @"parse %@'s param %@ is empty, location: line %ld col %ld", nameSpace, keyParam, (long)[parser lineNumber], (long)[parser columnNumber]);
            }
        }//for
    }
#endif
}




- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
#ifdef DEBUG
    NSAssert(NO, @"xml parse error line %ld col %ld", (long)[parser lineNumber], (long)[parser columnNumber]);
#endif
}

@end
