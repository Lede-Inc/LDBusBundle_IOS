//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "UITabBarControllerAdditions.h"

#import "TTUtil.h"
#import "UIViewControllerAdditions.h"

/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UITabBarControllerAdditions)
@implementation UITabBarController (TTCategory)


- (BOOL)canContainControllers {
    return YES;
}


- (UIViewController*)topSubcontroller {
    if (self.tabBar.selectedItem == self.moreNavigationController.tabBarItem) {
        return self.moreNavigationController;
    }
    else {
        return self.selectedViewController;
    }
}


- (void)addSubcontroller:(UIViewController*)controller
                animated:(BOOL)animated
              transition:(UIViewAnimationTransition)transition {
    [self updateSelectController:controller];
}


- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
    [self updateSelectController:controller];
}


- (void)updateSelectController:(UIViewController *)selectedViewController{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]){
        [self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
    }

    self.selectedViewController = selectedViewController;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]){
        [self.delegate tabBarController:self didSelectViewController:selectedViewController];
    }
}


@end
