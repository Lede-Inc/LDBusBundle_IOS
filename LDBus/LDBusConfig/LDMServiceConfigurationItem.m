//
//  LDMServiceConfigurationItem.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMServiceConfigurationItem.h"

@implementation LDMServiceConfigurationItem
@synthesize serviceName = _serviceName;
@synthesize protocolString = _protocolString;
@synthesize classString = _classString;

-(id) initWithServiceConfigurationItem:(NSString *)theServiceName
                              protocol:(NSString *)theProtocolString
                                 class:(NSString *)theClassString {
    self = [super init];
    if(self){
        _serviceName = theServiceName;
        _protocolString = theProtocolString;
        _classString = theClassString;
    }
    return self;
}

@end
