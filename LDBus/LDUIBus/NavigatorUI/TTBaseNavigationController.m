//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTBaseNavigationController.h"

#define LD_FLIP_TRANSITION_DURATION 0.7f

@implementation TTBaseNavigationController

#pragma mark -
#pragma mark UINavigationController

/**
 * 重载Navigaiton Pop ViewController的方法
 */
- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
    if (animated) {
        UIViewAnimationTransition transition = UIViewAnimationTransitionNone;
        if (transition) {
            UIViewAnimationTransition inverseTransition = [self invertTransition:transition];
            return [self popViewControllerAnimatedWithTransition:inverseTransition];
        }
    }
    
    return [super popViewControllerAnimated:animated];
}


/**
 * 获取某个动画的反转动画
 */
- (UIViewAnimationTransition)invertTransition:(UIViewAnimationTransition)transition {
    switch (transition) {
        case UIViewAnimationTransitionCurlUp:
            return UIViewAnimationTransitionCurlDown;
        case UIViewAnimationTransitionCurlDown:
            return UIViewAnimationTransitionCurlUp;
        case UIViewAnimationTransitionFlipFromLeft:
            return UIViewAnimationTransitionFlipFromRight;
        case UIViewAnimationTransitionFlipFromRight:
            return UIViewAnimationTransitionFlipFromLeft;
        default:
            return UIViewAnimationTransitionNone;
    }
}



#pragma mark -
#pragma mark Public
/**
 * 定制动画push
 */
- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition {
    [self pushViewController:controller animated:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:LD_FLIP_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:YES];
    [UIView commitAnimations];
}


/**
 * 定制动画pop
 */
- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition {
    UIViewController* poppedController = [self popViewControllerAnimated:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:LD_FLIP_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:NO];
    [UIView commitAnimations];
    
    return poppedController;
}


/**
 * 动画结束时响应
 */
- (void)pushAnimationDidStop {
}



@end

