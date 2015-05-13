//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "UIViewControllerAdditions.h"

#import "TTUtil.h"
#import "TTDebug.h"

/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIViewControllerAdditions)
@implementation UIViewController (TTCategory)

- (BOOL)canContainControllers {
    return NO;
}


- (BOOL)canBeTopViewController {
    return YES;
}


//打开一个viewController的parentViewController， 如果没有则返回nil
- (UIViewController*)superController {
    UIViewController* parent = self.parentViewController;
    if (nil != parent) {
        return parent;
    } else {
        return nil;
    }
}


- (UIViewController*)topSubcontroller {
    return nil;
}


- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
    if (self.navigationController) {
        [self.navigationController addSubcontroller:controller
                                           animated:animated
                                         transition:transition];
    }
}


- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}

@end
