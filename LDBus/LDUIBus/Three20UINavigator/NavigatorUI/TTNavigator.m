//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTNavigator.h"

// UI
#import "TTPopupViewController.h"

// UINavigator
#import "TTURLMap.h"
#import "TTURLAction.h"

// UINavigator (private)
#import "TTBaseNavigationController.h"
#import "TTBaseNavigatorInternal.h"

// UICommon
#import "UIViewControllerAdditions.h"

// Core
#import "TTDebug.h"


@implementation TTNavigator

/**
 * 获取App target中全局导航的navigator
 */
+ (TTNavigator*)navigator {
  TTBaseNavigator* navigator = [TTBaseNavigator globalNavigator];
  if (nil == navigator) {
    navigator = [[[TTNavigator alloc] init] autorelease];
    // setNavigator: retains.
    [super setGlobalNavigator:navigator];
  }
  // If this asserts, it's likely that you're attempting to use two different navigator
  // implementations simultaneously. Be consistent!
  TTDASSERT([navigator isKindOfClass:[TTNavigator class]]);
  return (TTNavigator*)navigator;
}



/**
 * A popup controller is a view controller that is presented over another controller, but doesn't
 * necessarily completely hide the original controller (like a modal controller would). A classic
 * example is a status indicator while something is loading.
 * 在ipad系统中通过popover展示界面
 *
 * @private
 */
- (void)presentPopupController: (TTPopupViewController*)controller
              parentController: (UIViewController*)parentController
                        action: (TTURLAction*)action {
  if (nil != action.sourceButton) {
    [controller showFromBarButtonItem: action.sourceButton
                             animated: action.animated];

  } else {
    parentController.popupViewController = controller;
    controller.superController = parentController;
    [controller showInView: parentController.view
                  animated: action.animated];
  }
}



/**
 * Present a view controller that strictly depends on the existence of the parent controller.
 * 打开一个只依赖于当前父controller的controller
 *
 * @protected
 */
- (void)presentDependantController: (UIViewController*)controller
                  parentController: (UIViewController*)parentController
                              mode: (TTNavigationMode)mode
                            action: (TTURLAction*)action {

  if ([controller isKindOfClass:[TTPopupViewController class]]) {
    TTPopupViewController* popupViewController = (TTPopupViewController*)controller;
    [self presentPopupController: popupViewController
                parentController: parentController
                          action: action];

  }
  // 如果不是popViewController,则根据mode打开viewController
  else {
    [super presentDependantController: controller
                     parentController: parentController
                                 mode: mode
                               action: action];
  }
}




/**
 * 获得当前可视的viewController
 *
 * @protected
 */
- (UIViewController*)getVisibleChildController:(UIViewController*)controller {
    return [super getVisibleChildController:controller];
}


/**
 * 重载保存的ModelViewController
 *
 * @public
 */
- (void)reload {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[TTModelViewController class]]) {
    TTModelViewController* ttcontroller = (TTModelViewController*)controller;
    [ttcontroller reload];
  }
}


/**
 * 类继承方法重写
 *
 * @public
 */
- (Class)navigationControllerClass {
  return [TTBaseNavigationController class];
}


@end
