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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This object bundles up a set of parameters and ships them off
 * to TTBasicNavigator's openURLAction method. This object is designed with the chaining principle
 * in mind. Once you've created a TTURLAction object, you can apply any other property to the
 * object via the apply* methods. Each of these methods returns self, allowing you to chain them.
 *
 * Example:
 * [[TTURLAction actionWithURLPath:@"tt://some/path"] applyAnimated:YES];
 * Create an autoreleased URL action object with the path @"tt://some/path" that is animated.
 *
 * For the default values, see the apply method documentation below.
 */
@interface TTURLAction : NSObject {
  NSString*     _urlPath;
  NSString*     _parentURLPath;
  NSDictionary* _query;
  BOOL          _animated;

  CGRect        _sourceRect;
  UIView*       _sourceView;
  UIBarButtonItem* _sourceButton;

  UIViewAnimationTransition _transition;
    BOOL          _ifNeedPresent;
}

@property (nonatomic, copy)   NSString*     urlPath;
@property (nonatomic, copy)   NSString*     parentURLPath;
@property (nonatomic, copy)   NSDictionary* query;
@property (nonatomic, assign) BOOL          animated;
@property (nonatomic, assign) CGRect        sourceRect;
@property (nonatomic, retain) UIView*       sourceView;
@property (nonatomic, retain) UIBarButtonItem* sourceButton;
@property (nonatomic, assign) UIViewAnimationTransition transition;
@property (nonatomic, assign) BOOL          ifNeedPresent;

/**
 * Create an autoreleased TTURLAction object.
 */
+ (id)action;

/**
 * Create an autoreleased TTURLAction object with a URL path.
 */
+ (id)actionWithURLPath:(NSString*)urlPath;

/**
 * Initialize a TTURLAction object with a URL path.
 *
 * Designated initializer.
 */
- (id)initWithURLPath:(NSString*)urlPath;

- (id)init;

/**
 * @default nil
 */
- (TTURLAction*)applyParentURLPath:(NSString*)parentURLPath;

/**
 * @default nil
 */
- (TTURLAction*)applyQuery:(NSDictionary*)query;

/**
 * @default NO
 */
- (TTURLAction*)applyAnimated:(BOOL)animated;

/**
 * @default NO
 */
- (TTURLAction*)applyIfNeedPresent:(BOOL)ifNeedPresent;

/**
 * @default CGRectZero
 */
- (TTURLAction*)applySourceRect:(CGRect)sourceRect;

/**
 * @default nil
 */
- (TTURLAction*)applySourceView:(UIView*)sourceView;

/**
 * @default nil
 */
- (TTURLAction*)applySourceButton:(UIBarButtonItem*)sourceButton;

/**
 * @default UIViewAnimationTransitionNone
 */
- (TTURLAction*)applyTransition:(UIViewAnimationTransition)transition;


@end
