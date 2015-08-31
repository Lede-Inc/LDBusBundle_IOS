//
//  LDMURLViewCtrlPatternConfigurationItem.h
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { PatternNone = 0, PatternShare, PatternModal, PatternPop, PatternPush } PatternType;


@interface LDMURLViewCtrlPatternConfigurationItem : NSObject {
    NSString *_patternWebPath;  //为了区分默认的pattern，自定义selector需要再增加一层path
    NSString *_patternWebQuery;  //配置url pattern的query
    NSString *_patternWebFrage;  //配置url pattern的fragement
    PatternType _patternType;  // pattern的打开方式
    NSString *_patternParent;  // pattern的父controller
}

@property (readonly, nonatomic) NSString *patternWebPath;
@property (readonly, nonatomic) NSString *patternWebQuery;
@property (readonly, nonatomic) NSString *patternWebFrage;
@property (readonly, nonatomic) PatternType patternType;
@property (readonly, nonatomic) NSString *patternParent;

- (id)initWithURLViewCtrlPatternConfigurationItem:(NSString *)thePatternWebPath
                                            query:(NSString *)thePatternWebQuery
                                        fragement:(NSString *)thePatternWebFrage
                                             type:(PatternType)thePatternType
                                           parent:(NSString *)thePatternParent;


@end
