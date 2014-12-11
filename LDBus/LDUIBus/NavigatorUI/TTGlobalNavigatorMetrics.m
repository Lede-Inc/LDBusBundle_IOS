//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TTGlobalNavigatorMetrics.h"
// UINavigator
#import "TTBaseNavigator.h"
// Core
#import "TTGlobalCoreRects.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
UIInterfaceOrientation TTInterfaceOrientation() {
  UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
  if (UIDeviceOrientationUnknown == orient) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    return [TTBaseNavigator globalNavigator].visibleViewController.interfaceOrientation;
#else
    return UIInterfaceOrientationPortrait;
#endif

  } else {
    return orient;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect TTScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIInterfaceOrientationIsLandscape(TTInterfaceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat TTStatusHeight() {
  UIInterfaceOrientation orientation = TTInterfaceOrientation();
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return [UIScreen mainScreen].applicationFrame.origin.x;

  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return -[UIScreen mainScreen].applicationFrame.origin.x;

  } else {
    return [UIScreen mainScreen].applicationFrame.origin.y;
  }
}