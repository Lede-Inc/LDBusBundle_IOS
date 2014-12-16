//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTURLAction;
@class TTURLMap;
@class TTURLPattern;
@class TTURLNavigatorPattern;

/**
 * A URL-based navigation system.
 */
@interface TTBaseNavigator : NSObject <UIPopoverControllerDelegate> {
    UIWindow*                   _window;
    UIViewController*           _rootViewController;
    id                          _popoverController;
}

//The window that contains the view controller hierarchy
@property (nonatomic, retain) UIWindow* window;

//The controller that is at the root of the view controller hierarchy.
@property (nonatomic, readwrite) UIViewController* rootViewController;

//The currently visible view controller.
@property (nonatomic, readonly) UIViewController* visibleViewController;

//The view controller that is currently on top of the navigation stack. 
//忽略search display controoler，不属于导航体系的一部分
@property (nonatomic, readonly) UIViewController* topViewController;
@property (nonatomic, readonly)NSString *URL;


+ (TTBaseNavigator*)globalNavigator;
+ (void)setGlobalNavigator:(TTBaseNavigator*)navigator;

/**
 * 在parentURL下展示一个ViewController
 *
 * @public
 */
- (BOOL)presentController: (UIViewController*)controller
            parentURLPath: (NSString*)parentURLPath
              withPattern: (TTURLNavigatorPattern*)pattern
                   action: (TTURLAction*)action;

/**
 * Removes all view controllers from the window and releases them.
 */
- (void)removeAllViewControllers;
- (UIViewController*)getVisibleChildController:(UIViewController*)controller;




@end
