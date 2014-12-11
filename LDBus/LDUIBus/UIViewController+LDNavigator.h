//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * @category UIViewController (LDNavigator)
 * 主要用作ViewController继承，给基本viewController添加initWithNavigationURL:query供继承
 * 也可以不继承，另外提供整个navigator的垃圾回收：
 * 在收到内存搞紧之后，通过调用[UIViewController doNavigatorGarbageCollection]
 */
@interface UIViewController (LDNavigator)

/**
 * The default initializer sent to view controllers opened through Navigator.
 */
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;

/**
 * 当前正在展示ViewController的URL
 */
@property (nonatomic, readonly) NSString* navigatorURL;

/**
 * The URL that was used to load this controller through Navigator.
 * 这个是参加Navigator导航生成ViewController的最原始的URL，不允许改变
 */
@property (nonatomic, copy) NSString* originalNavigatorURL;

/**
 * 如果担心内存释放的问题，可以通过这个方法强制进行垃圾回收
 */
+ (void)doNavigatorGarbageCollection;


/**
 * 向导航器中的垃圾箱中添加Controller
 */
+ (void)ttAddNavigatorController:(UIViewController*)controller;

/**
 * 销毁垃圾箱中的ViewController
 * @protected
 */
- (void)unsetNavigatorProperties;


@end
