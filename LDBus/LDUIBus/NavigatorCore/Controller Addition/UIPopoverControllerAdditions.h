//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIPopoverController (TTCategory)

/**
 * Determines whether a controller is primarily a container of other controllers.
 *
 * @default NO
 */
@property (nonatomic, readonly) BOOL canContainControllers;

/**
 * Whether or not this controller should ever be counted as the "top" view controller. This is
 * used for the purposes of determining which controllers should have modal controllers presented
 * within them.
 *
 * @default YES; subclasses may override to NO if they so desire.
 */
@property (nonatomic, readonly) BOOL canBeTopViewController;

/**
 * The view controller that contains this view controller.
 *
 * This is just like parentViewController, except that it is not readonly.  This property offers
 * custom UIViewController subclasses the chance to tell TTNavigator how to follow the hierarchy
 * of view controllers.
 */
@property (nonatomic, retain) UIViewController* superController;


@end
