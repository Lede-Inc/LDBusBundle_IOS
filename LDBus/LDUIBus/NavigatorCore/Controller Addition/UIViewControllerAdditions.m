//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//



#import "UIViewControllerAdditions.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCore.h"
#import "TTDebug.h"

static NSMutableDictionary* gSuperControllers = nil;
static NSMutableDictionary* gPopupViewControllers = nil;

// Garbage collection state
static NSMutableSet*        gsCommonControllers     = nil;
static NSTimer*             gsGarbageCollectorTimer = nil;

static const NSTimeInterval kGarbageCollectionInterval = 20;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(UIViewControllerAdditions)

@implementation UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Garbage Collection
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Common used here in the name because this is the UICommon lib.
 */
+ (NSMutableSet*)ttCommonControllers {
  if (nil == gsCommonControllers) {
    gsCommonControllers = [[NSMutableSet alloc] init];
  }

  return gsCommonControllers;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)doCommonGarbageCollection {
  NSMutableSet* controllers = [UIViewController ttCommonControllers];

  [self doGarbageCollectionWithSelector: @selector(unsetCommonProperties)
                          controllerSet: controllers];

  if ([controllers count] == 0) {
    TTDCONDITIONLOG(0,
                    @"Killing the common garbage collector.");
    [gsGarbageCollectorTimer invalidate];
    TT_RELEASE_SAFELY(gsGarbageCollectorTimer);
    TT_RELEASE_SAFELY(gsCommonControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)ttAddCommonController:(UIViewController*)controller {
    [[UIViewController ttCommonControllers] addObject:controller];
    if (nil == gsGarbageCollectorTimer) {
      gsGarbageCollectorTimer =
        [[NSTimer scheduledTimerWithTimeInterval: kGarbageCollectionInterval
                                          target: [UIViewController class]
                                        selector: @selector(doCommonGarbageCollection)
                                        userInfo: nil
                                         repeats: YES] retain];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBeTopViewController {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)superController {
  UIViewController* parent = self.parentViewController;
  if (nil != parent) {
    return parent;

  } else {
    NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
    return [gSuperControllers objectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSuperController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
  if (nil != viewController) {
    if (nil == gSuperControllers) {
      gSuperControllers = TTCreateNonRetainingDictionary();
    }
    [gSuperControllers setObject:viewController forKey:key];

    [UIViewController ttAddCommonController:self];

  } else {
    [gSuperControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topSubcontroller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)ttPreviousViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex > 0) {
      return [viewControllers objectAtIndex:controllerIndex-1];
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:controllerIndex+1];
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)popupViewController {
  NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
  return [gPopupViewControllers objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPopupViewController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
  if (viewController) {
    if (!gPopupViewControllers) {
      gPopupViewControllers = TTCreateNonRetainingDictionary();
    }
    [gPopupViewControllers setObject:viewController forKey:key];

    [UIViewController ttAddCommonController:self];

  } else {
    [gPopupViewControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  if (self.navigationController) {
    [self.navigationController addSubcontroller:controller animated:animated
                               transition:transition];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontroller {
  [self removeFromSupercontrollerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontrollerAnimated:(BOOL)animated {
  if (self.navigationController) {
    [self.navigationController popViewControllerAnimated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissModalViewController {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
    [self dismissModalViewControllerAnimated:YES];
#else
    [self dismissViewControllerAnimated:YES completion:nil];
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * The basic idea.
 * Whenever you set the original navigator URL path for a controller, we add the controller
 * to a global navigator controllers list. We then run the following garbage collection every
 * kGarbageCollectionInterval seconds. If any controllers have a retain count of 1, then
 * we can safely say that nobody is using it anymore and release it.
 */
+ (void)doGarbageCollectionWithSelector:(SEL)selector controllerSet:(NSMutableSet*)controllers {
  if ([controllers count] > 0) {
    TTDCONDITIONLOG(0,
                    @"Checking %lu controllers for garbage.", (unsigned long)[controllers count]);

    NSSet* fullControllerList = [controllers copy];
    for (UIViewController* controller in fullControllerList) {

      // Subtract one from the retain count here due to the copied set.
      NSInteger retainCount = [controller retainCount] - 1;

      TTDCONDITIONLOG(0,
                      @"Retain count for %X is %ld", (unsigned int)controller, (long)retainCount);

      if (retainCount == 1) {
        // If this fails, you've somehow added a controller that doesn't use
        // the given selector. Check the controller type and the selector itself.
        TTDASSERT([controller respondsToSelector:selector]);
        if ([controller respondsToSelector:selector]) {
          [controller performSelector:selector];
        }

        // The object's retain count is now 1, so when we release the copied set below,
        // the object will be completely released.
        [controllers removeObject:controller];
      }
    }

    TT_RELEASE_SAFELY(fullControllerList);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetCommonProperties {
  TTDCONDITIONLOG(0,
                  @"Unsetting this controller's properties: %X", (unsigned int)self);

  self.superController = nil;
  self.popupViewController = nil;
}


@end
