//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTBaseNavigator.h"

/**
 * A URL-based navigation system with built-in persistence.
 * Add support for model-based controllers and implement the legacy global instance accessor.
 */
@interface TTNavigator : TTBaseNavigator {
    
}

+ (TTNavigator*)navigator;

/**
 * Reloads the content in the visible view controller.
 */
- (void)reload;

@end
