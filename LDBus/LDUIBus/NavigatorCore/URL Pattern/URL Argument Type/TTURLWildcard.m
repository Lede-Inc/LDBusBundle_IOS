//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "TTURLWildcard.h"
#import "TTUtil.h"

@implementation TTURLWildcard
@synthesize name = _name;
@synthesize argIndex = _argIndex;
@synthesize argType = _argType;


- (id)init
{
    self = [super init];
    if (self) {
        _argIndex = NSNotFound;
        _argType = TTURLArgumentTypeNone;
    }
    return self;
}


- (void)dealloc
{
    TT_RELEASE_SAFELY(_name);
    [super dealloc];
}


/**
 * 作为设置selector的选项，传入任何text都属于匹配项
 */
- (BOOL)match:(NSString *)text
{
    return YES;
}
@end
