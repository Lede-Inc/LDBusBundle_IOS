//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "UIViewControllerAdditions.h"

#import "TTUtil.h"
#import "TTDebug.h"

static NSMutableDictionary* gSuperControllers = nil;

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
    }
    
    else {
        NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
        return [gSuperControllers objectForKey:key];
    }
}

- (void)setSuperController:(UIViewController*)viewController {
    NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
    if (nil != viewController) {
        if (nil == gSuperControllers) {
            gSuperControllers = TTCreateNonRetainingDictionary();
        }
        [gSuperControllers setObject:viewController forKey:key];
        
        //[UIViewController ttAddCommonController:self];
    } else {
        [gSuperControllers removeObjectForKey:key];
    }
}


- (UIViewController*)topSubcontroller {
    return nil;
}


- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
    //只有通过Push的controller才会进入该函数
    if (self.navigationController) {
        [self.navigationController addSubcontroller:controller
                                           animated:animated
                                         transition:transition];
        controller.superController = self;
    }
}


- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}

@end
