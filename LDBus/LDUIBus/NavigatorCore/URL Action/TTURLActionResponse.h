//
//  TTURLActionResponse.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/24/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTURLNavigatorPattern;
@interface TTURLActionResponse : NSObject {
    UIViewController *_viewController;          //返回的ViewController
    TTURLNavigatorPattern *_navigatorPattern;   //返回ViewController对应的URLPattern
    NSString *_bundleName;                      //返回ViewController所属的bundle
}

@property (retain, nonatomic) UIViewController *viewController;
@property (retain, nonatomic) TTURLNavigatorPattern *navigatorPattern;
@property (retain, nonatomic) NSString *bundleName;

- (id)initWithViewController: (UIViewController *)theViewController
                     pattern:(TTURLNavigatorPattern *)theNavigatorPattern
                sourceBundle:(NSString *)theBundleName;

@end
