//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TTNavigatorRootContainer;
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
  id        _popoverController;
  BOOL                        _opensExternalURLs;
  id<TTNavigatorRootContainer>  _rootContainer;
}

//The window that contains the view controller hierarchy
@property (nonatomic, retain) UIWindow* window;

//A container that holds the root view controller.
@property (nonatomic, assign) id<TTNavigatorRootContainer> rootContainer;

//The controller that is at the root of the view controller hierarchy.
@property (nonatomic, readonly) UIViewController* rootViewController;

//The currently visible view controller.
@property (nonatomic, readonly) UIViewController* visibleViewController;

//The view controller that is currently on top of the navigation stack. 
//忽略search display controoler，不属于导航体系的一部分
@property (nonatomic, readonly) UIViewController* topViewController;
@property (nonatomic, readonly)NSString *URL;

//Allows URLs to be opened externally if they don't match any patterns.
@property (nonatomic) BOOL opensExternalURLs;


+ (TTBaseNavigator*)navigatorForView:(UIView*)view;
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



@end
