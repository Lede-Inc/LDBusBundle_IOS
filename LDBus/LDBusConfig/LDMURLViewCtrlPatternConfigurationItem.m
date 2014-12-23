//
//  LDMURLViewCtrlPatternConfigurationItem.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMURLViewCtrlPatternConfigurationItem.h"

@implementation LDMURLViewCtrlPatternConfigurationItem
@synthesize patternWebPath = _patternWebPath;
@synthesize patternWebQuery = _patternWebQuery;
@synthesize patternWebFrage = _patternWebFrage;
@synthesize patternType = _patternType;
@synthesize patternParent = _patternParent;

-(id)initWithURLViewCtrlPatternConfigurationItem:(NSString *)thePatternWebPath
                                           query:(NSString *)thePatternWebQuery
                                       fragement:(NSString *)thePatternWebFrage
                                            type:(PatternType)thePatternType
                                          parent:(NSString *)thePatternParent{
    self = [super init];
    if(self){
        _patternWebPath = thePatternWebPath;
        _patternWebQuery = thePatternWebQuery;
        _patternWebFrage = thePatternWebFrage;
        _patternType = thePatternType;
        _patternParent = thePatternParent;
    }
    return self;
}

@end
