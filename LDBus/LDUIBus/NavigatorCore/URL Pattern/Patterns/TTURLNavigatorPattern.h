//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import "TTURLPattern.h"
#import "TTNavigationMode.h"

@interface TTURLNavigatorPattern : TTURLPattern {
    Class _targetClass;  // url对应的class
    id _targetObject;  // url对应的object
    TTNavigationMode _navigationMode;  //导航方式
    NSString *_parentURL;  // parenturl
    NSInteger _argumentCount;  //配置初始化selector的参数个数
}

@property (nonatomic, assign) Class targetClass;
@property (nonatomic, assign) id targetObject;
@property (nonatomic, readonly) TTNavigationMode navigationMode;
@property (nonatomic, copy) NSString *parentURL;
@property (nonatomic, assign) NSInteger argumentCount;

@property (nonatomic, readonly) BOOL isUniversal;
@property (nonatomic, readonly) BOOL isFragment;

- (id)initWithTarget:(id)target;
- (id)initWithTarget:(id)target mode:(TTNavigationMode)navigationMode;

/**
 * 解析URLPattern
 */
- (void)compile;

/**
 * 判断调用URL是否和pattern匹配
 */
- (BOOL)matchURL:(NSURL *)URL;

/**
 * 通过pattern中的parse选项的个数来第一步判断pattern是否相同
 */
- (NSComparisonResult)compareSpecificity:(TTURLPattern *)pattern2;

/*
 * 通过url生成object，直接通过object invoke一个object
 */
- (id)invoke:(id)target withURL:(NSURL *)URL query:(NSDictionary *)query;

/**
 * 通过target class alloc init 或者调用selector初始化一个object
 * @return the newly created object or nil if something went wrong
 */
- (id)createObjectFromURL:(NSURL *)URL query:(NSDictionary *)query;

@end
