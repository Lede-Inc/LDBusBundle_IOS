//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "TTURLLiteral.h"

// Core
#import "TTCorePreprocessorMacros.h"


@implementation TTURLLiteral
@synthesize name = _name;


- (void)dealloc {
    TT_RELEASE_SAFELY(_name);
    [super dealloc];
}


- (BOOL)match:(NSString*)text {
    return [text isEqualToString:_name];
}


- (NSString*)convertPropertyOfObject:(id)object {
    return _name;
}


@end
