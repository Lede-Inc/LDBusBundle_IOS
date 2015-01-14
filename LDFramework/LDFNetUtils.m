//
//  LDFNetUtils.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/13/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFNetUtils.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

static LDFNetUtils *moniter;

@implementation LDFNetUtils

@dynamic status;
@dynamic isWifi;
@dynamic isNetworAvailable;
@synthesize reachability = _reachability;
@synthesize carrier = _carrier;

+ (LDFNetUtils *)sharedNetMoniter
{
    if (!moniter) {
        moniter = [[LDFNetUtils alloc] init];
    }
    return moniter;
}

- (id)init
{
    if (self = [super init]) {
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
        if (self.isNetworAvailable) {
            if (self.isWifi) {
            } else {
            }
        }
    }
    return self;
}

- (BOOL)isWifi
{
    return self.status == ReachableViaWiFi;
}

- (BOOL)isNetworAvailable
{
    return self.status != NotReachable;
}

- (NetworkStatus)status
{
#if 0
    return ReachableViaWWAN;
#else
    return _reachability.currentReachabilityStatus;
#endif
}

@end
