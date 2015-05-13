//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "UINavigationControllerAdditions.h"

#import "TTUtil.h"
#import "UIViewControllerAdditions.h"

/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UINavigationControllerAdditions)
@implementation UINavigationController (TTCategory)


- (BOOL)canContainControllers {
    return YES;
}


- (UIViewController*)topSubcontroller {
    return self.topViewController;
}


- (void)addSubcontroller:(UIViewController*)controller
                animated:(BOOL)animated
              transition:(UIViewAnimationTransition)transition {
    //tip:不能定制NavigationController的push动画, transition无效
    [self pushViewController:controller animated:animated];
}


- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
    if ([self.viewControllers indexOfObject:controller] != NSNotFound
        && controller != self.topViewController) {
        [self popToViewController:controller animated:animated];
    }
}

@end
