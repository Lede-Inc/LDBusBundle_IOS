//
//  LDMBundleConfigurationItem.m
//  LDBusBundle
//
//  Created by 庞辉 on 12/22/14.
//  Copyright (c) 2014 庞辉. All rights reserved.
//

#import "LDMBundleConfigurationItem.h"

@implementation LDMBundleConfigurationItem
@synthesize isMainBundle = _isMainbundle;
@synthesize hasFirstEnterVC = _hasFirstEnterVC;
@synthesize hasBundleImage = _hasBundleImage;
@synthesize bundleName = _bundleName;

@synthesize bundleWebHost = _bundleWebHost;
@synthesize updateURL = _updateURL;
@synthesize installLevel = _installLevel;
@synthesize connectorClass = _connectorClass;

@synthesize urlViewCtrlConfigurationList = _urlViewCtrlConfigurationList;
@synthesize serviceConfigurationList = _serviceConfigurationList;
@synthesize postMessageConfigurationList = _postMessageConfigurationList;
@synthesize receiveMessageConfigurationList = _receiveMessageConfigurationList;

+ (BOOL)isURLConfigurationSame:(id)arg1 toItem:(id)arg2{
    return YES;
}

+ (BOOL)checkDuplicateBetweenItem:(id)arg1 andItem:(id)arg2{
    return NO;
}

- (BOOL)checkDuplicateMyself {
    return YES;
}

-(id)initWithBundleConfigurationItem:(NSString *)theBundleName
                              isMain:(BOOL) theIsMainBundle
                     hasFirstEnterVC:(BOOL) theHasFirstEnterVC
                      hasBundleImage:(BOOL) theHasBundleImage
                          bundleHost:(NSString *) theBundleWebHost
                           updateURL:(NSString *) theUpdateURL
                        installLevel:(NSString *) theInstallLevel
                      connectorClass:(NSString *) theConnetorClass;{
    self = [super init];
    if(self){
        _bundleName = theBundleName;
        _isMainbundle = theIsMainBundle;
        _hasFirstEnterVC = theHasFirstEnterVC;
        _hasBundleImage = theHasBundleImage;
        _bundleWebHost = theBundleWebHost;
        _updateURL = theUpdateURL;
        _installLevel = theInstallLevel;
        _connectorClass = theConnetorClass;
        
        _urlViewCtrlConfigurationList = nil;
        _serviceConfigurationList = nil;
        _postMessageConfigurationList = nil;
        _receiveMessageConfigurationList = nil;
    }
    return self;
}


@end
