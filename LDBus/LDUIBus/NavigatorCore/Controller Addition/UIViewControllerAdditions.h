//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (TTCategory)

/**
 * 返回当前ViewController是否是能够包含其他Controller的Container
 * @default NO, NaviagationController和UITabViewController为YES
 */
@property (nonatomic, readonly) BOOL canContainControllers;


/**
 * 返回当前ViewController是否能够Present Modal controllers
 * @default YES; 
 */
@property (nonatomic, readonly) BOOL canBeTopViewController;


/**
 * The view controller that contains this view controller.
 *
 * This is just like parentViewController, except that it is not readonly.  This property offers
 * custom UIViewController subclasses the chance to tell Navigator how to follow the hierarchy
 * of view controllers.
 */
@property (nonatomic, readonly) UIViewController* superController;


/**
 * The child of this view controller which is most visible.
 *
 * This would be the selected view controller of a tab bar controller, or the top
 * view controller of a navigation controller.  This property offers custom UIViewController
 * subclasses the chance to tell Navigator how to follow the hierarchy of view controllers.
 */
- (UIViewController*)topSubcontroller;


/**
 * Displays a controller inside this controller.
 *
 * TTURLMap uses this to display newly created controllers.  The default does nothing --
 * UIViewController categories and subclasses should implement to display the controller
 * in a manner specific to them.
 */
- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition;


/**
 * Brings a controller that is a child of this controller to the front.
 *
 * TTURLMap uses this to display controllers that exist already, but may not be visible.
 * The default does nothing -- UIViewController categories and subclasses should implement
 * to display the controller in a manner specific to them.
 */
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated;
@end
