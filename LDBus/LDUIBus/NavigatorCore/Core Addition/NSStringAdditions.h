//
//  Created by 庞辉 on 12/5/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (TTAdditions)

/**
 * Parses a URL query-key string into NSArray
 */
- (NSArray *)queryKeysSortByFIFO:(NSStringEncoding)encoding;

/**
 * Parses a URL query string into a dictionary where the values are arrays.
 */
- (NSDictionary *)queryContentsUsingEncoding:(NSStringEncoding)encoding;

@end
