//
//  LDMContainer.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @class bus总线全局控制中心
 */
@class LDMBundle;
@class LDMUIBusCenter;
@class LDMServiceBusCenter;
@class LDMMessageBusCenter;
@class UIViewController;


/**
 * @class LDMContainer
 * 1. 三条总线总的调度中心，因为三条总线的基本单位都是bundle
 * 2. bundle的加载和管理在总调度中心完成, 当程序启动预加载过程中，通过读取mainbundle中各个
 *    bundle的配置文件,初始化一个bundle管理对象
 * 3. 每条总线各自面向加载bundle列表处理消息
 */
@interface LDMContainer : NSObject {
    NSMutableDictionary *_bundlesMap;
    NSString *_mainScheme;
}

@property (nonatomic, readonly)NSMutableDictionary *bundlesMap;

/**
 * 获取各个bus的调度中心
 */
+(LDMContainer*) container;

/**
 * bus center preload config
 * private: 每个bundle一个scheme
 */
-(void) preloadConfig;


/**
 * 对于保证整个app统一scheme导航的初始化
 */
-(void) preloadConfigWithScheme:(NSString *)scheme;

/**
 * 设置当前navigator的rootViewController
 */
-(BOOL) setNavigatorRootViewController:(UIViewController *)theRoot;

@end
