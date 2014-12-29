//
//  LDMURLActionHandlerConfigurationItem.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMURLViewCtrlConfigurationItem.h"

@implementation LDMURLViewCtrlConfigurationItem
@synthesize viewCtrlName = _viewCtrlName;
@synthesize viewCtrlClass = _viewCtrlClass;
@synthesize viewCtrlWebPath = _viewCtrlWebPath;
@synthesize viewCtrlWebQuery = _viewCtrlWebQuery;
@synthesize viewCtrlDefaultType = _viewCtrlDefaultType;
@synthesize viewCtrlDefaultParent = _viewCtrlDefaultParent;
@synthesize urlViewCtrlPatternConfigurationList = _urlViewCtrlPatternConfigurationList;


-(id)initWithURLViewCtrlConfigurationItem:(NSString *)theViewCtrlName
                                    class:(NSString *)theViewCtrlClass
                                  webPath:(NSString *)theViewCtrlWebPath
                                 webQuery:(NSString *)theViewCtrlWebQuery
                                   parent:(NSString *)theViewCtrlDefaultParent
                                     type:(PatternType)theViewCtrlDefaultType{
    self = [super init];
    if(self){
        _viewCtrlName = theViewCtrlName;
        _viewCtrlClass = theViewCtrlClass;
        _viewCtrlWebPath = theViewCtrlWebPath;
        _viewCtrlWebQuery = theViewCtrlWebQuery;
        _viewCtrlDefaultParent = theViewCtrlDefaultParent;
        _viewCtrlDefaultType = theViewCtrlDefaultType;
        _urlViewCtrlPatternConfigurationList = nil;
    }
    return self;
}

@end
