//
//  LDBundleBusCenter.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class bus总线全局控制中心
 */
@class LDBundle;
@class LDUIBusCenter;
@class LDServiceBusCenter;
@class LDMessageBusCenter;
@class UIViewController;


/**
 * @class LDBusCenter
 * 1. 三条总线总的调度中心，因为三条总线的基本单位都是bundle
 * 2. bundle的加载和管理在总调度中心完成, 当程序启动预加载过程中，通过读取mainbundle中各个
 *    bundle的配置文件,初始化一个bundle管理对象
 * 3. 每条总线各自面向加载bundle列表处理消息
 */
@interface LDBusCenter : NSObject {
    NSMutableDictionary *_bundlesMap;
}

@property (nonatomic, readonly)NSMutableDictionary *bundlesMap;

/**
 * 获取各个bus的调度中心
 */
+(LDBusCenter*) busCenter;

/**
 * bus center preload config
 */
-(void) preloadConfig;


/**
 * 设置当前navigator的rootViewController
 */
-(BOOL) setNavigatorRootViewController:(UIViewController *)theRoot;

@end
