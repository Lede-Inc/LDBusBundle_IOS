//
//  LDMRoutes.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/25/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSMutableDictionary *routeControllersMap = nil;

/**
 * @class LDMRoutes
 * 管理某个scheme下的routePattern
 * 注意此类主要用来管理WebURL，所以对于routePattern的handler限定为
 * 遵守指定协议LDMBusWebControllerProtocol的web容器
 */
@interface LDMRoutes : NSObject {
}

/**
 * 根据scheme创建一个LDMRoutes pattern管理器
 */
+ (instancetype)routesForScheme:(NSString *)scheme;


/**
 * 给指定scheme管理器中添加routePattern
 * 每个routePattern制定一个遵守指定协议的webController
 */
- (void)addRoute:(NSString *)routePattern
      webHandler:(NSString *)webControllerClassString
         isModal:(BOOL)isModal;


/**
 * 查看特殊Scheme管理器是否能够处理URL
 */
+ (BOOL)canRouteURL:(NSURL *)URL;
- (BOOL)canRouteURL:(NSURL *)URL;  // instance method


/**
 * 执行特殊scheme的处理
 */
+ (BOOL)routeURL:(NSURL *)URL;
- (BOOL)routeURL:(NSURL *)URL;

@end
