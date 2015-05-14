//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTURLAction;
@class TTURLMap;
@class TTURLPattern;
@class TTURLNavigatorPattern;

/**
 * A URL-based navigation system.
 */
@interface LDMNavigator : NSObject <UIPopoverControllerDelegate> {
    UIWindow*                   _window;
    id                          _popoverController;
}

//The window that contains the view controller hierarchy
@property (nonatomic, retain) UIWindow* window;

//The controller that is at the root of the view controller hierarchy.
@property (nonatomic, readwrite, assign) UIViewController* rootViewController;
@property (nonatomic, readonly) UIViewController* visibleViewController;
@property (nonatomic, readonly) UIViewController* topViewController;
@property (nonatomic, readonly)NSString *URL;



+ (LDMNavigator*)navigator;


/**
 * 在parentURL下展示一个ViewController
 *
 * @public
 */
- (BOOL)presentController: (UIViewController*)controller
            parentURLPath: (NSString*)parentURLPath
              withPattern: (TTURLNavigatorPattern*)pattern
                   action: (TTURLAction*)action;



@end
