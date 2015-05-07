//
//  LDMUIBusConnector.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/6/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LDMNavigator;
@class TTURLMap;
@class TTURLPattern;
@class TTURLAction;
@class TTURLActionResponse;

/**
 * @class LDMUIBusConnector
 * 每个bundle的UI Bus连接器，供各个bundle继承使用,
 *    1)负责消息的发送和接收，并根据消息完成UI总线的初始化，展示
 *
 * 每个uibus connector由各自bundle去操作，
 *    1)如果异构bundle，可以按照自己的逻辑去完成上述动作
 *    2)如果同构bundle，可以直接调用总线提供的方法去完成初始化
 */
@interface LDMUIBusConnector : NSObject{
    
}

/**
 * 从buscenter 赋值, 继承者可以重载自己加载map；
 */
-(void) setBundleURLMap:(TTURLMap *)map;
-(void) setBelongBundle:(NSString *)bundleName;

/**
 * 从buscenter 赋值, 继承者可以重载自己加载map；
 */
-(void) setGlobalNavigator:(LDMNavigator*) navigator;

//处理接收的URL消息Action
-(BOOL) dealWithURLMessageFromBus:(TTURLAction *)action;

//处理获取ViewController的消息
-(TTURLActionResponse *)handleURLActionRequest:(TTURLAction *)action;


@end


/**
 * 当继承Connector的时候，只需要重载如下三个方法，其他可以不用动
 */
@interface LDMUIBusConnector(ToBeOverwrite)

/**
 * 接收消息，查看消息是否能够处理
 */
-(BOOL) canOpenInBundle:(NSString *)url;


/**
 * 根据URLAction生成ViewController
 */
-(UIViewController*)viewControllerForAction:(TTURLAction*)action;


/**
 * 自定义如何展示ViewController，直接调用navigator获取当前view栈的情况
 */
- (BOOL)presentViewController:(UIViewController*)controller
                    navigator:(LDMNavigator*)navigator
                       action:(TTURLAction *)action;

@end
