//
//  LDUIBusConnector.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/6/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LDNavigator;
@class TTURLMap;
@class TTURLAction;
@class TTURLPattern;


/**
 * @class LDUIBusConnector
 * 每个bundle的UI Bus连接器，供各个bundle继承使用,
 *    1)负责消息的发送和接收，并根据消息完成UI总线的初始化，展示
 *
 * 每个uibus connector由各自bundle去操作，
 *    1)如果异构bundle，可以按照自己的逻辑去完成上述动作
 *    2)如果同构bundle，可以直接调用总线提供的方法去完成初始化
 */
@interface LDUIBusConnector : NSObject{
    
}

/**
 * 从buscenter 赋值, 继承者可以重载自己加载map；
 */
-(void) setBundleURLMap:(TTURLMap *)map;
/**
 * 从buscenter 赋值, 继承者可以重载自己加载map；
 */
-(void) setGlobalNavigator:(LDNavigator*) navigator;


//可以在继承类中重定向
//处理接收的URL消息Action
-(BOOL) dealWithURLMessageFromBus:(TTURLAction *)action;

//接收消息，查看消息是否能够处理
-(BOOL) IsURLCanOpenInBundle:(NSString *)url;

//根据URLAction生成ViewController
- (UIViewController*)viewControllerForAction:(TTURLAction*)action;

//根据指定Pattern生成ViewController
- (UIViewController*)viewControllerForURL: (NSString*)URL
                                    query: (NSDictionary*)query
                                  pattern: (TTURLPattern**)pattern;


@end
