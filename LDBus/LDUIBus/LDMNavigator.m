//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "LDMNavigator.h"

// UINavigator
#import "TTURLAction.h"

// UINavigator (private)
#import "TTBaseNavigationController.h"
#import "LDMBaseNavigatorInternal.h"

// UICommon
#import "UIViewControllerAdditions.h"
#import "UIPopoverControllerAdditions.h"

// Core
#import "TTDebug.h"


@implementation LDMNavigator

/**
 * 获取App target中全局导航的navigator
 */
+ (LDMNavigator*)navigator {
  LDMBaseNavigator* navigator = [LDMBaseNavigator globalNavigator];
  if (nil == navigator) {
    navigator = [[LDMNavigator alloc] init];
    // setNavigator: retains.
    [super setGlobalNavigator:navigator];
  }
  // If this asserts, it's likely that you're attempting to use two different navigator
  // implementations simultaneously. Be consistent!
  TTDASSERT([navigator isKindOfClass:[LDMNavigator class]]);
  return (LDMNavigator*)navigator;
}



/**
 * A popup controller is a view controller that is presented over another controller, but doesn't
 * necessarily completely hide the original controller (like a modal controller would). A classic
 * example is a status indicator while something is loading.
 * 在ipad系统中通过popover展示界面
 *
 * @private
 */
- (void)presentPopupController: (UIPopoverController*)controller
              parentController: (UIViewController*)parentController
                        action: (TTURLAction*)action {
  if (nil != action.sourceButton) {
      [controller presentPopoverFromBarButtonItem:action.sourceButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:action.animated];
  } else {
    parentController.popupViewController = (UIViewController *)controller;
    controller.superController = parentController;
      [controller presentPopoverFromRect:action.sourceRect
                                  inView:parentController.view
                permittedArrowDirections:UIPopoverArrowDirectionAny
                                animated:action.animated];
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

  if ([controller isKindOfClass:[UIPopoverController class]]) {
    UIPopoverController* popupViewController = (UIPopoverController*)controller;
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
 * 类继承方法重写
 *
 * @public
 */
- (Class)navigationControllerClass {
  return [TTBaseNavigationController class];
}


@end
