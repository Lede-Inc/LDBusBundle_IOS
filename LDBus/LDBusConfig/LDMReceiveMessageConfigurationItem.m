//
//  LDMReceiveMessageConfigurationItem.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMReceiveMessageConfigurationItem.h"

@implementation LDMReceiveMessageConfigurationItem
@synthesize messageName = _messageName;
@synthesize messageCode = _messageCode;
@synthesize receiveObjectString = _receiveObjectString;


- (id)initWithReceiveMessageConfigurationItem:(NSString *)theMessageName
                                         code:(NSString *)theMessageCode
                                receiveObject:(NSString *)theReceiveObjectString
{
    self = [super init];
    if (self) {
        _messageName = theMessageName;
        _messageCode = theMessageCode;
        _receiveObjectString = theReceiveObjectString;
    }

    return self;
}


@end
