//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTURLPatternText <NSObject>
@required
- (BOOL)match:(NSString*)text;
- (NSString*)convertPropertyOfObject:(id)object;
@end
