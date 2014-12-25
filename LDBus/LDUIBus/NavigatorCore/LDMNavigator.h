//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTBaseNavigator.h"
#import "TTNavigationMode.h"
/**
 * A URL-based navigation system with built-in persistence.
 * Add support for model-based controllers and implement the legacy global instance accessor.
 */
@interface LDMNavigator : TTBaseNavigator {
    
}

+ (LDMNavigator*)navigator;


/**
 * Present a view controller that strictly depends on the existence of the parent controller.
 * 打开一个只依赖于当前父controller的controller
 *
 * @protected
 */
- (void)presentDependantController: (UIViewController*)controller
                  parentController: (UIViewController*)parentController
                              mode: (TTNavigationMode)mode
                            action: (TTURLAction*)action;

@end
