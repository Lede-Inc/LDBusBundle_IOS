//
//  LDFNetUtils.h
//  LDBusBundle
//
//  Created by 庞辉 on 1/13/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface LDFNetUtils : NSObject
{
    Reachability *_reachability;
    NSString *_carrier;
}
@property (nonatomic, readonly) Reachability *reachability;
@property (nonatomic, readonly) NetworkStatus status;
@property (nonatomic, readonly) BOOL isWifi;
@property (nonatomic, readonly) BOOL isNetworAvailable;
@property (nonatomic, readonly) NSString *carrier;

+ (LDFNetUtils *)sharedNetMoniter;

@end