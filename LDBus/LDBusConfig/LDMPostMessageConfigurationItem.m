//
//  LDMPostMessageConfigurationItem.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMPostMessageConfigurationItem.h"

@implementation LDMPostMessageConfigurationItem
@synthesize messageName = _messageName;
@synthesize messageCode = _messageCode;

-(id) initWithPostMessageConfigurationItem:(NSString *)theMessageName
                                      code:(NSString *)theMessageCode {
    self = [super init];
    if(self){
        _messageName = theMessageName;
        _messageCode = theMessageCode;
    }
    
    return self;
}

@end

