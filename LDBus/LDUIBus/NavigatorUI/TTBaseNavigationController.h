//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * The base navigation view controller that overrides popViewControllerAnimated and provides
 * inverse animations when popping a view controller.
 * 你可以直接用UINavigationController，如果你继承该NavigationController，你可以设置自定义的push和pop动画
 */
@interface TTBaseNavigationController : UINavigationController {

}

/**
 * TODO: Move this to a private category header.
 */
- (void)pushAnimationDidStop;


/**
 * 以定制动画pushViewController
 */
- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition;


/**
 * Pops a view controller with a transition other than the standard sliding animation.
 * 以定制动画popViewController
 */
- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition;


@end
