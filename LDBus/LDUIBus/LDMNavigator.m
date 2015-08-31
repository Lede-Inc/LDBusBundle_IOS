//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMNavigator.h"

// UINavigator
#import "LDMUIBusCenter.h"
#import "TTURLAction.h"
#import "TTURLActionResponse.h"
#import "TTURLMap.h"
#import "TTURLNavigatorPattern.h"

#import "LDMNavigatorInternal.h"
#import "UIViewControllerAdditions.h"
#import "UIViewController+LDMNavigator.h"

// Core
#import "TTUtil.h"
#import "TTDebug.h"


static LDMNavigator *gNavigator = nil;

/**
 * @class 全局UI导航的navigator
 */
@implementation LDMNavigator
@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

#pragma mark -
#pragma mark - initial method

/**
 * 初始化navigator
 */
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


/**
 * 销毁对象
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIWindowDidBecomeKeyNotification
                                                  object:nil];
    _window = nil;
    _rootViewController = nil;
    _popoverController = nil;
}


/**
 * 获取App target中全局导航的navigator
 */
+ (LDMNavigator *)navigator
{
    if (nil == gNavigator) {
        gNavigator = [[LDMNavigator alloc] init];
    }

    return (LDMNavigator *)gNavigator;
}


/**
 * 返回当前的window
 */
- (UIWindow *)window
{
    if (nil == _window) {
        NSAssert(NO, @"window is not initial");
    }
    return _window;
}


- (void)setWindow:(UIWindow *)theWindow
{
    NSAssert(theWindow != nil, @"window can't not be nil");
    _window = theWindow;

    // window只能设置一次，设置时监听当前window的rootViewControlelr的变化
    if (_window != nil) {
        [_window addObserver:self
                  forKeyPath:@"rootViewController"
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                     context:nil];
    }
}

/**
 * 当监听到RootViewController变化时，取最新的值进行判断和设置navigator.window新的rootViewController
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == _window && [keyPath isEqualToString:@"rootViewController"]) {
        id newRootViewController = change[@"new"];
        NSLog(@">>>new rootViewController %@ be setted>>>>>>>>",
              NSStringFromClass([newRootViewController class]));
        [self setRootViewController:newRootViewController];
    }
}


/**
 * 设置rootViewController
 * @public
 */
- (void)setRootViewController:(UIViewController *)controller
{
    if (controller != _rootViewController) {
        NSLog(@"<<<<<<<<rootViewController_changed>>>>>>>>>>>");
        _rootViewController = controller;

        //当setroot的时候，显示window
        [_window makeKeyAndVisible];
    }
}

#pragma mark -
#pragma mark present ViewController
/**
 * 返回给定ViewController的parentViewController
 * 如果传入了parentURL，则返回url对应的ViewController，
 * 否则把当前Navigation体系中的topViewController做为父ViewController
 *
 * @private
 */
- (UIViewController *)parentForController:(UIViewController *)controller
                              isContainer:(BOOL)isContainer
                            parentURLPath:(NSString *)parentURLPath
                         navigatorPattern:(TTURLNavigatorPattern **)pattern
{
    if (controller == _rootViewController) {
        return nil;

    } else {
        //如果当前viewController是第一个ViewController，且不是一个容器的ViewController
        if (nil == _rootViewController && !isContainer) {
            _window.rootViewController = [[[self navigationControllerClass] alloc] init];
        }

        //如果传入了一个parentURL，则通过该URL生成一个ViewController
        if (nil != parentURLPath) {
            TTURLAction *action = [TTURLAction actionWithURLPath:parentURLPath];
            action.isDirectDeal = NO;
            TTURLActionResponse *response = [LDMUIBusCenter handleURLActionRequest:action];
            *pattern = response.navigatorPattern;
            return response.viewController;
        }

        //其他情况下返回当前导航体系的TopViewController作为父ViewController
        else {
            UIViewController *parent = self.topViewController;
            if (parent != controller) {
                return parent;

            } else {
                return nil;
            }
        }
    }
}


/**
 * 完成在parentController下展示ModalViewController
 * 如果controller事一个NaviagtionController，则直接presentModal
 * 否则将controller强制push到一个NavigationController，然后prensetModal
 * @private
 */
- (void)presentModalController:(UIViewController *)controller
              parentController:(UIViewController *)parentController
                      animated:(BOOL)animated
                    transition:(NSInteger)transition
{
    controller.modalTransitionStyle = transition;

    if ([controller isKindOfClass:[UINavigationController class]]) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
        [parentController presentModalViewController:controller animated:animated];
#else
        [parentController presentViewController:controller animated:animated completion:nil];
#endif

    } else {
        UINavigationController *navController = [[[self navigationControllerClass] alloc] init];
        navController.modalTransitionStyle = transition;
        navController.modalPresentationStyle = controller.modalPresentationStyle;
        [navController pushViewController:controller animated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
            [parentController presentModalViewController:navController animated:animated];
#else
            [parentController presentViewController:navController
                                           animated:animated
                                         completion:nil];
#endif
        });
        NSLog(@">>>>>>>presentViewController finished>>>>>>>>>>>>>>>>>");
    }
}


/**
 * 完成在sourceButton或者sourceView显示一个PopoverViewController
 *
 * @private
 */
- (void)presentPopoverController:(UIViewController *)controller
                    sourceButton:(UIBarButtonItem *)sourceButton
                      sourceView:(UIView *)sourceView
                      sourceRect:(CGRect)sourceRect
                        animated:(BOOL)animated
{
    NSAssert(nil != sourceButton || nil != sourceView,
             @"source Button or source view cannot be nil at time");
    if (nil == sourceButton && nil == sourceView) {
        return;
    }

    //如果当前navigator中有popOverController，则先dismiss
    if (nil != _popoverController) {
        [_popoverController dismissPopoverAnimated:animated];
        _popoverController = nil;
    }

    _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    if (_popoverController != nil) {
        [(UIPopoverController *)_popoverController setDelegate:self];
    }

    if (nil != sourceButton) {
        [_popoverController presentPopoverFromBarButtonItem:sourceButton
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:animated];

    } else {
        [_popoverController presentPopoverFromRect:sourceRect
                                            inView:sourceView
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:animated];
    }
}


/**
 * dismiss 当前Navigator导航下打开的PopoverController
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == _popoverController) {
        _popoverController = nil;
    }
}


/**
 * 在parentViewController展示一个ViewController
 * 如果viewController存在，则退到该ViewController，
 * 否则在parentViewController展示一个新的ViewController
 *
 * @private
 */
- (BOOL)presentController:(UIViewController *)controller
         parentController:(UIViewController *)parentController
                     mode:(TTNavigationMode)mode
                   action:(TTURLAction *)action
{
    BOOL didPresentNewController = YES;

    if (nil == _rootViewController) {
        _window.rootViewController = controller;
    }

    //展示一个已经存在的ViewController
    else {
        // superController是指push：前一个push成为Parent；
        //如果事tab，则tabController成为parent
        UIViewController *previousSuper = controller.superController;
        if (nil != previousSuper) {
            if (previousSuper != parentController) {
                // The controller already exists, so we just need to make it visible
                for (UIViewController *superController = previousSuper; controller;) {
                    UIViewController *nextSuper = superController.superController;
                    [superController bringControllerToFront:controller animated:!nextSuper];
                    controller = superController;
                    superController = nextSuper;
                }
            }
            didPresentNewController = NO;

        }


        //展示一个新的独立的viewController
        else if (nil != parentController) {
            [self presentDependantController:controller
                            parentController:parentController
                                        mode:mode
                                      action:action];
        }
    }

    return didPresentNewController;
}


/**
 * 在parentURL下展示一个ViewController
 *
 * @public
 */
- (BOOL)presentController:(UIViewController *)controller
            parentURLPath:(NSString *)parentURLPath
              withPattern:(TTURLNavigatorPattern *)pattern
                   action:(TTURLAction *)action
{
    BOOL didPresentNewController = NO;

    if (nil != controller) {
        UIViewController *topViewController = self.topViewController;
        if (controller != topViewController) {
            TTURLNavigatorPattern *parentPattern = nil;
            parentURLPath = (parentURLPath && ![parentURLPath isEqualToString:@""])
                                ? parentURLPath
                                : pattern.parentURL;
            UIViewController *parentController =
                [self parentForController:controller
                              isContainer:[controller canContainControllers]
                            parentURLPath:parentURLPath
                         navigatorPattern:&parentPattern];

            //如果当前parentViewController不在topViewController
            if (nil != parentController && parentController != topViewController) {
                BOOL didParentPresent =
                    [self presentController:parentController
                           parentController:nil
                                       mode:TTNavigationModeNone
                                     action:[TTURLAction actionWithURLPath:nil]];

                //当didParentPresetn＝YES，说明parentCtrller并没有展示，需要以当前top为parent展示；
                //没有展示的原因:parent不是生成另外一个容器，而只是新生成的一个viewController，加上如下代码支持不管parent是否为一个新生成的viewCtrl，都支持导航；
                if (didParentPresent) {
                    [self presentController:parentController
                           parentController:topViewController
                                       mode:parentPattern.navigationMode ?: TTNavigationModeNone
                                     action:[TTURLAction actionWithURLPath:nil]];
                }
            }

            didPresentNewController = [self presentController:controller
                                             parentController:parentController
                                                         mode:pattern.navigationMode
                                                       action:action];
        }
    }
    return didPresentNewController;
}


#pragma mark -
#pragma mark Public property

/**
 * 返回当前可见的ViewController
 * 如果root是一个viewController，且没有modalViewController，则返回当前root；
 * 如果root是一个带ModalViewController的viewController，则找到最后一个ModalViewController，然后获取最前面的viewController
 * 如果root是navigationController或者tabbarViewController，则直接获取最前面的ViewController
 *
 * 如何获取最前面的viewController，不断的嵌套查询，直到最后getVisibleChildController是nil
 */
- (UIViewController *)visibleViewController
{
    UIViewController *controller = _rootViewController;
    while (nil != controller) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
        UIViewController *child = controller.modalViewController;
#else
        UIViewController *child = controller.presentedViewController;
#endif

        if (nil == child) {
            child = [self getVisibleChildController:controller];
        }

        if (nil != child) {
            controller = child;

        } else {
            return controller;
        }
    }
    return nil;
}


/**
 * 获取当前ViewController的可见viewController，通过调用三种类型ViewController的topSubViewController：
 * 如果是ViewController，则返回nil，
 * 如果是NavigationController，返回当前Navigation的topViewController；
 * 如果是TabBarController， 返回当前选中的tabBarItem，注意moreNavigationController
 *
 */
- (UIViewController *)getVisibleChildController:(UIViewController *)controller
{
    return controller.topSubcontroller;
}


/**
 * 返回当前navigator的topViewController
 * popupViewController不能作为topViewController；
 * 从root往下找，直到child为nil，返回child的父controller；
 */
- (UIViewController *)topViewController
{
    UIViewController *controller = _rootViewController;
    while (controller) {
        UIViewController *child = nil;
        if (!child || ![child canBeTopViewController]) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
            child = controller.modalViewController;
#else
            child = controller.presentedViewController;
#endif
        }
        if (!child) {
            child = controller.topSubcontroller;
        }
        if (child) {
            if (child == _rootViewController) {
                return child;

            } else {
                controller = child;
            }

        } else {
            return controller;
        }
    }
    return nil;
}


/**
 * 返回当前navigator的topViewController的URL
 */
- (NSString *)URL
{
    return self.topViewController.navigatorURL;
}


#pragma mark -
#pragma mark - frontViewController Now-Not-Used
/**
 * 返回当前Navigator的最前面的viewController
 * 先获取当前rootViewController的Navigation导航器，获取topviewController
 * 如果Naviation导航器不存在，则直接从rootViewController查找（目前还没有Navigation导航）
 *
 * @public
 */
- (UIViewController *)frontViewController
{
    UINavigationController *navController = self.frontNavigationController;
    if (navController) {
        return [LDMNavigator frontViewControllerForController:navController];

    } else {
        return [LDMNavigator frontViewControllerForController:_rootViewController];
    }
}


/**
 * 返回当前viewController的Navigation导航器
 * tip: 假设了TabBarController的每个tab均包含了一个Navigation导航器
 * 如果rootViewController是tab导航，则返回当前选中tab的Navigation
 * 如果rootViewController是Naviagtion导航，则直接返回；其他导航否则返回nil
 *
 * @private
 */
- (UINavigationController *)frontNavigationController
{
    if ([_rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)_rootViewController;

        if (tabBarController.selectedViewController) {
            return (UINavigationController *)tabBarController.selectedViewController;

        } else {
            return (UINavigationController *)[tabBarController.viewControllers objectAtIndex:0];
        }

    } else if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)_rootViewController;

    } else {
        return nil;
    }
}


/**
 * 获得当前可见的viewController
 * 如果当前viewController是一个UITabBarController，则返回当前选中tab的Viewcontroller（如果没有选择，返回第一个tab）
 * 如果当前viewController是一个UINavigationController,则返回当前navigation的topViewController
 * 如果当前viewController包含ModalViewController， 则嵌套返回最前面的ModalViewController
 *
 * @private
 */
+ (UIViewController *)frontViewControllerForController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)controller;

        if (tabBarController.selectedViewController) {
            controller = tabBarController.selectedViewController;

        } else {
            controller = [tabBarController.viewControllers objectAtIndex:0];
        }

    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)controller;
        controller = navController.topViewController;
    }

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    if (controller.modalViewController) {
        return [LDMNavigator frontViewControllerForController:controller.modalViewController];
    }
#else
    if (controller.presentedViewController) {
        return [LDMNavigator frontViewControllerForController:controller.presentedViewController];
    }
#endif
    else {
        return controller;
    }
}
@end


#pragma mark -
#pragma mark - TTInterval
@implementation LDMNavigator (TTInternal)
/**
 * Present a view controller that strictly depends on the existence of the parent controller.
 */
- (void)presentDependantController:(UIViewController *)controller
                  parentController:(UIViewController *)parentController
                              mode:(TTNavigationMode)mode
                            action:(TTURLAction *)action
{
    if (mode == TTNavigationModeModal) {
        [self presentModalController:controller
                    parentController:parentController
                            animated:action.animated
                          transition:action.transition];

    } else if (mode == TTNavigationModePopover) {
        [self presentPopoverController:controller
                          sourceButton:action.sourceButton
                            sourceView:action.sourceView
                            sourceRect:action.sourceRect
                              animated:action.animated];

    } else {
        [parentController addSubcontroller:controller
                                  animated:action.animated
                                transition:action.transition];
    }
}


- (Class)navigationControllerClass
{
    return [UINavigationController class];
}


@end
